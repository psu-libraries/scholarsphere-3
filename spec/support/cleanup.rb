# frozen_string_literal: true

require 'active_fedora/cleaner'

class Cleanup
  def self.directories
    FileUtils.rm_rf(ENV['REPOSITORY_FILESTORE'])
    FileUtils.mkdir_p(ENV['REPOSITORY_FILESTORE'])
    FileUtils.rm_rf(ScholarSphere::Application.config.network_ingest_directory)
    FileUtils.mkdir_p(ScholarSphere::Application.config.network_ingest_directory)
    FileUtils.rm_rf(ScholarSphere::Application.config.public_zipfile_directory)
    FileUtils.mkdir_p(ScholarSphere::Application.config.public_zipfile_directory)
  end
end

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
    Cleanup.directories
  end

  # Only clean Fedora and Solr unless explicitly requested
  config.before do |example|
    if example.metadata.fetch(:clean, nil)
      ActiveFedora::Cleaner.clean!
      DatabaseCleaner.clean_with(:truncation)
      Cleanup.directories
    end
  end

  # Use typical Rails database cleaning procedures before each test
  config.before do |_example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    Sipity::Workflow.destroy_all
    Sufia::PermissionTemplate.destroy_all
    initialize_default_adminset
  end

  config.after do
    DatabaseCleaner.clean
  end
end
