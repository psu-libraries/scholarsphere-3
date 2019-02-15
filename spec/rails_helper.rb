# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

if ENV['COVERAGE'] || ENV['TRAVIS']
  require 'simplecov'
  require 'coveralls'
  SimpleCov.root(File.expand_path('..', __dir__))
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start('rails') do
    add_filter '/spec'
    add_filter '/tasks'
  end
  SimpleCov.command_name 'spec'
end

require 'rake'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'equivalent-xml/rspec_matchers'
require 'byebug' unless ENV['TRAVIS']

# For feature testing with JS
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require 'selenium-webdriver'

Capybara.register_driver :chrome do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile['extensions.password_manager_enabled'] = false
  Capybara::Selenium::Driver.new(app, browser: :chrome, profile: profile)
end

Capybara.register_driver(:chrome_new) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: ['no-sandbox', 'headless', 'disable-gpu', 'single-process'] }
  )
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities)
end

Capybara.javascript_driver = :chrome_new
Capybara.default_driver = :rack_test
Capybara.server = :webrick

def travis?
  ENV.fetch('TRAVIS', false)
end

def external_files?
  ENV.fetch('REPOSITORY_EXTERNAL_FILES', 'false') == 'true'
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Monkeypatch FactoryGirl so we can use RSpec's latest syntax to mock responses with factory objects
FactoryGirl::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Gets around a bug in RSpec where helper methods that are defined in views aren't
  # getting scoped correctly and RSpec returns "does not implement" errors. So we
  # can disable verify_partial_doubles if a particular test is giving us problems.
  # Ex:
  #   describe "problem test", verify_partial_doubles: false do
  #     ...
  #   end
  config.before do |example|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = example.metadata.fetch(:verify_partial_doubles, true)
    end
  end
end
