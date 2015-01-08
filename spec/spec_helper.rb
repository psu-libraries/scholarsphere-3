# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'rake'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'support/cleanup'
require 'equivalent-xml/rspec_matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  # Make Capybara wait a bit longer so sluggish AJAX reqs can finish
  # on Travis
  Capybara.default_wait_time = 15

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature
  config.include UserLogin, type: :feature

  config.infer_spec_type_from_file_location!
end

module FactoryGirl
  def self.find_or_create(handle, by=:login)
    tmpl = FactoryGirl.build(handle)
    tmpl.class.send("find_by_#{by}".to_sym, tmpl.send(by)) || FactoryGirl.create(handle)
  end
end
