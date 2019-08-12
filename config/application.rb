# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'
require 'socket'
require 'sprockets'
require 'resolv'
require 'uri'
require 'sufia/version'
require 'rdf/rdfxml'
require 'webmock' unless Rails.env.production?

WebMock.disable! if Rails.env.development?

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module ScholarSphere
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Environment variables list here are defined in application.yml
    config.ffmpeg_path = ENV.fetch('ffmpeg_path', 'ffmpeg')
    config.derivatives_path = ENV.fetch('derivatives_path', File.join(Rails.root, 'tmp', 'derivatives'))
    config.service_instance = ENV.fetch('service_instance', Socket.gethostname)
    config.virtual_host = ENV.fetch('virtual_host', "https://#{Socket.gethostname}")
    config.google_analytics_id = ENV.fetch('google_analytics_id', nil)
    config.stats_email = ENV.fetch('stats_email', 'ScholarSphere Stats <umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu>')
    config.contact_email = ENV.fetch('contact_email', 'ssphere-support@psu.edu')
    config.subject_prefix = ENV.fetch('subject_prefix', 'ScholarSphere Contact Form - ')
    config.backup_directory = Rails.root.join(ENV.fetch('backup_directory', 'backups'))
    config.upload_limit = ENV.fetch('upload_limit', 10.gigabyte.to_s)
    config.admin_group = ENV.fetch('admin_group', 'umg/up.ss.admin')
    config.network_ingest_directory = Pathname.new(ENV.fetch('network_ingest_directory', 'tmp/ingest-development'))
    config.zipfile_size_threshold = ENV.fetch('zipfile_size_threshold', 500_000_000).to_i
    config.public_zipfile_directory = Pathname.new(ENV.fetch('public_zipfile_directory', 'public/zip-development'))

    # DOI Handle used with either EZID or DateCite EZ API
    config.doi_handle = ENV.fetch('doi_handle', 'doi:10.33532')

    # Set the  system to read only mode.  Does not allow new uploads, file edits, new collections, and collection edits
    config.read_only = ENV.fetch('read_only', false)

    config.scholarsphere_version = 'v3.9'
    config.scholarsphere_release_date = 'August 13, 2019'
    config.redis_namespace = 'scholarsphere'

    # Number of fits array items shown on the Generic File show page
    config.fits_message_length = 5

    config.assets.enabled = true
    config.assets.compress = !Rails.env.development?

    # Custom directories with classes and modules you want to be eager loaded.
    config.eager_load_paths += Dir["#{config.root}/lib/**/*"]
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths += %W(#{config.root}/app/models/datastreams)
    config.eager_load_paths += %W(#{config.root}/app/forms/concerns)
    config.eager_load_paths += %W(#{config.root}/app/renderers)
    config.eager_load_paths += %W(#{config.root}/app/prepends)

    config.i18n.enforce_available_locales = true

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Always render things in UTF-8
    config.action_dispatch.default_charset = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.max_upload_file_size = 20 * 1024 * 1024 * 1024 # 20GB

    # html maintenance response
    config.middleware.use Rack::Maintenance,
                          file: Rails.root.join('public', 'maintenance.html')

    # Time (in seconds) to wait before trying any LDAP queries if initial response is unwilling.
    config.ldap_unwilling_sleep = 2

    # allow errors to be raised in callbacks
    ActiveSupport.halt_callback_chains_on_return_false = false

    config.action_mailer.default_options = { from: ENV.fetch('no_reply_email', 'no_reply@scholarsphere.psu.edu') }
    config.action_mailer.default_url_options = { host: config.service_instance, protocol: 'https' }

    # Inject new behaviors into existing classes without having to override the entire class itself.
    config.to_prepare do
      Sufia::StatsUsagePresenter.prepend PrependedPresenters::StatsUsageBehavior
      API::ZoteroController.prepend PrependedControllers::WithUserKey
      AttachFilesToWorkJob.prepend PrependedJobs::WithQueuedFiles
      AttachFilesToWorkJob.prepend PrependedJobs::WithNotification
      CurationConcerns::Renderers::AttributeRenderer.prepend PrependedRenderers::ConfiguredMicrodata
      CurationConcerns::Renderers::AttributeRenderer.prepend PrependedRenderers::WithLists
      Sufia::HomepageController.prepend PrependedControllers::WithRecentPresenters
      FeaturedWorkList.prepend PrependedModels::WithFeaturedPresenters
      CurationConcerns::CollectionSearchBuilder.prepend PrependedSearchBuilders::WithMoreRows
      CurationConcerns::MemberPresenterFactory.file_presenter_class = FileSetPresenter
      Sufia::CreateWithFilesActor.prepend PrependedActors::WithVisibilityAttributes
      Sufia::Statistics::TermQuery.prepend PrependedServices::WithNullTermQuery
      Sufia::QueryService.prepend PrependedServices::WithDateUploaded
      Sufia::FeaturedWorkListsController.prepend PrependedControllers::WithFeaturedListHash

      # Prepending class methods
      if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
        CurationConcerns::WorkingDirectory.singleton_class.send(:prepend, PrependedServices::WithExternalFileSupport)
      end
    end
  end
end
