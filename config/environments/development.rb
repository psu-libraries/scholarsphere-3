Sufia::Engine.configure do
  config.contact_email = 'DLT-GAMMA-PROJECT@lists.psu.edu'
  config.from_email = "ScholarSphere Form <scholarsphere-service-support@dlt.psu.edu>"
  config.logout_url = 'https://webaccess.psu.edu/cgi-bin/logout?http://localhost:3000/'
  config.login_url = 'https://webaccess.psu.edu/?cosign-localhost&http://localhost:3000/dashboard'
end
ScholarSphere::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.log_level = :debug

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = false
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

end
