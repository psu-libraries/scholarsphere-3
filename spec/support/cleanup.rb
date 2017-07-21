# frozen_string_literal: true
require "active_fedora/cleaner"

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Clear all test emails that were sent
  config.before do
    ActionMailer::Base.deliveries.clear
  end

  # Ensure we begin with a blank slate
  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
    ActiveFedora::Cleaner.clean!
  end

  # Only clean Fedora and Solr unless explicitly requested
  config.before :each do |example|
    ActiveFedora::Cleaner.clean! if example.metadata.fetch(:clean, nil)
  end

  # Use typical Rails database cleaning procedures before each test
  config.before :each do |_example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
