# frozen_string_literal: true

require 'fcrepo_wrapper'
require 'fcrepo_wrapper/rake_task'
require 'solr_wrapper'
require 'active_fedora/cleaner'

namespace :solr do
  desc 'Starts a configured solr instance for local development and testing'
  task start: :environment do
    solr.extract_and_configure
    solr.start
    solr.create(name: 'hydra-development', dir: solr_config)
    solr.create(name: 'hydra-test', dir: solr_config)
  end

  def solr_config
    File.join(Rails.root, 'solr', 'config')
  end

  def solr
    @solr ||= SolrWrapper.default_instance(
      port: '8983',
      instance_dir: 'tmp/solr',
      download_dir: 'tmp'
    )
  end
end

namespace :dev do
  desc "Cleans out everything. Everything. Don't try this at home."
  task clean: :environment do
    ActiveFedora::Cleaner.clean!
    cleanout_redis
    clear_directories
    Rake::Task['db:reset'].invoke
    Rake::Task['sufia:default_admin_set:create'].invoke
    Rake::Task['curation_concerns:workflow:load'].invoke
  end

  def clear_directories
    FileUtils.rm_rf(Sufia.config.derivatives_path)
    FileUtils.mkdir_p(Sufia.config.derivatives_path)
    FileUtils.rm_rf(Sufia.config.upload_path.call)
    FileUtils.mkdir_p(Sufia.config.upload_path.call)
    FileUtils.rm_rf(ENV['REPOSITORY_FILESTORE'])
    FileUtils.mkdir_p(ENV['REPOSITORY_FILESTORE'])
  end

  def cleanout_redis
    Redis.current.keys.map { |key| Redis.current.del(key) }
  rescue => e
    Logger.new(STDOUT).warn "WARNING -- Redis might be down: #{e}"
  end
end
