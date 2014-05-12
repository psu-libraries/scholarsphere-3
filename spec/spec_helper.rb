# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'rake'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    before_files_count = GenericFile.count
    before_batches_count = Batch.count
    before_collections_count = Collection.count
    puts "WARNING: Your jetty is not clean, so tests may be funky! (#{before_files_count} files, #{before_batches_count} batches, #{before_collections_count} collections)" if before_files_count > 0 or before_batches_count > 0 or before_collections_count > 0
  end

  config.after(:all) do
    files_count = GenericFile.count
    batches_count = Batch.count
    collections_count = Collection.count
    puts "WARNING: #{files_count} files need cleaning up" if files_count > 0
    puts "WARNING: #{batches_count} batches need cleaning up" if batches_count > 0
    puts "WARNING: #{collections_count} batches need cleaning up" if collections_count > 0
  end

  config.after(:each) do
    # Unspoof the warden strategy.  See spec/support/user_login.rb for more info.
    unspoof_http_auth if example.options[:js]
  end

  # Make Capybara wait a bit longer so sluggish AJAX reqs can finish
  # on Travis
  Capybara.default_wait_time = 15

  # Use poltergeist (phantomjs driver) for feature tests requiring javascript
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
        js_errors: false,
        inspector: true,
        phantomjs_options: ['--proxy-type=none']
      })
  end
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature
  config.include UserLogin, type: :feature
end

module FactoryGirl
  def self.find_or_create(handle, by=:login)
    tmpl = FactoryGirl.build(handle)
    tmpl.class.send("find_by_#{by}".to_sym, tmpl.send(by)) || FactoryGirl.create(handle)
  end
end
