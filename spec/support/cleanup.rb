# frozen_string_literal: true
require 'active_fedora/cleaner'
# The other tests rely on a clean database *before* each test. So we
# clean up after ourselves here.
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:each) do
    # ActiveRecord cleanup
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    else
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    # ActiveFeora cleanup (solr and fedora)
    ActiveFedora::Cleaner.clean!

    # Delete test emails
    ActionMailer::Base.deliveries.clear

    # Clear out Redis
    begin
      $redis.keys('events:*').each { |key| $redis.del key }
      $redis.keys('User:*').each { |key| $redis.del key }
      $redis.keys('GenericFile:*').each { |key| $redis.del key }
    rescue => e
      Logger.new(STDOUT).warn "WARNING -- Redis might be down: #{e}"
    end
  end

  config.before :each do
    DatabaseCleaner.strategy = if Capybara.current_driver == :rack_test
                                 :transaction
                               else
                                 :truncation
                               end
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean if Capybara.current_driver == :rack_test
  end

  config.after(:each) do
    sleep 0.1
    Capybara.reset_sessions!
    sleep 0.1
    page.driver.reset!
    sleep 0.1
  end
end
