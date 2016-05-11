require 'fcrepo_wrapper'
require 'fcrepo_wrapper/rake_task'
require 'solr_wrapper'

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
  		        download_dir: 'tmp')
  end
end
