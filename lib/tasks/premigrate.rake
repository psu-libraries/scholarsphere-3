require 'action_view'
#require 'blacklight/solr_helper'
require 'rainbow'

include ActionView::Helpers::NumberHelper
#include Blacklight::SolrHelper

namespace :premigrate do

  ALL_ROWS = 1_000_000

  def logger
    Rails.logger
  end

  def get_all_batches
    batches = []
    query = Solrizer.solr_name('has_model', :symbol) + ':"' + Batch.to_class_uri + '"'
    results = ActiveFedora::SolrService.query(query, fl: "id", rows: ALL_ROWS)
    results.each do |batch|
      batch_id = batch["id"]
      if valid_id?(batch_id) && !batches.include?(batch_id)
        batches.push batch_id 
      end
    end
    batches
  end

  # batch_token should be an array of one element
  # ["info:fedora/scholarsphere:g732d900g"]
  def get_batch_id(batch_token)
    return if batch_token.blank?
    batch_id = batch_token.first.split('/').last
    batch_id
  end

  def valid_id?(identifier)
    identifier.to_s.start_with?(ScholarSphere::Application.config.id_namespace)
  end

  def get_batches_in_files
    batches = []
    query = Solrizer.solr_name('has_model', :symbol) + ':"' + GenericFile.to_class_uri + '"' 
    results = ActiveFedora::SolrService.query(query, fl: "id is_part_of_ssim", rows: ALL_ROWS)
    results.each do |file|
      begin
        batch_id = get_batch_id file['is_part_of_ssim'] 
        if valid_id?(batch_id) && !batches.include?(batch_id) 
          batches.push batch_id   
        end
      rescue Exception => e  
        logger.error "Error getting batch from file #{file}"
      end
    end
    batches
  end

  def get_missing_batches(verbose)
    all_batches = get_all_batches
    batches_in_files = get_batches_in_files
    missing_batches = []
    batches_in_files.each do |id|
      unless all_batches.include? id
        missing_batches.push(id)
      end
    end
    if verbose
      logger.info "Total batches: #{all_batches.length}"
      logger.info all_batches
      logger.info "Batches in files: #{batches_in_files.length}"
      logger.info batches_in_files
    end
    missing_batches
  end

  def fedora3_settings(file_name)
    fedora3_settings = YAML.load_file(file_name)
    fedora3_settings[Rails.env].symbolize_keys
  end

  desc "Get a list of missing batches"
  task "list_missing_batches", [:verbose] => :environment do |cmd, args|
    verbose = args[:verbose] == "true"
    missing_batches =  get_missing_batches(verbose)
    logger.info "Missing batches: #{missing_batches.length}"
    logger.info missing_batches
  end

  desc "Create missing batches"
  task create_missing_batches: :environment do
    missing_batches = get_missing_batches(false)
    if missing_batches.empty?
      logger.info "No missing batches need to be created"
    else
      logger.info "Creating #{missing_batches.length} batches..."
      missing_batches.each do |pid|
        begin
          logger.info "Batch: #{pid}"
          Batch.create(pid: pid)
        rescue Exception => e  
          logger.error "\tError creating batch #{pid}: #{e.message} #{e.backtrace.inspect}"          
        end
      end
    end
  end

  # This task is mostly for testing purposes to make sure we get all PIDs from Fedora 3.
  # To allow this task to be run from a version of the code that targets Fedora 3 
  # or Fedora 4 we must pass the file where the Fedora 3 settings are stored.
  desc "Fetches PIDs for all objects in Fedora 3 for our namespace"
  task "get_pids", [:fedora3_yml] => :environment do |cmd, args|
    file_name = args[:fedora3_yml]
    abort("Must specify a Fedora 3 YAML file") if file_name.nil?
    credentials = fedora3_settings(file_name)
    namespace = "scholarsphere"
    auditor = MigrateAuditFedora3.new(credentials[:url], credentials[:user], credentials[:password], namespace)
    puts auditor.pids
  end

  # This task is mostly for testing purposes to make sure we get all objects and their data.
  # To allow this task to be run from a version of the code that targets Fedora 3 
  # or Fedora 4 we must pass the file where the Fedora 3 settings are stored.
  desc "Fetched basic info (PID, model, title) for all objects in Fedora 3 in our namespace"
  task "get_info", [:fedora3_yml] => :environment do |cmd, args|
    file_name = args[:fedora3_yml]
    abort("Must specify a Fedora 3 YAML file") if file_name.nil?
    credentials = fedora3_settings(file_name)
    namespace = "scholarsphere"
    auditor = MigrateAuditFedora3.new(credentials[:url], credentials[:user], credentials[:password], namespace)
    auditor.pids.each do |pid|
      puts auditor.get_info(pid)
    end
  end  

  # Recreates data in migrate_audit SQL table with information about all Fedora 3 objects.
  # To allow this task to be run from a version of the code that targets Fedora 3 
  # or Fedora 4 we must pass the file where the Fedora 3 settings are stored.
  desc "Creates an audit for all Fedora 3 objects in our namespace"
  task "f3_audit", [:fedora3_yml] => :environment do |cmd, args|
    file_name = args[:fedora3_yml]
    abort("Must specify a Fedora 3 YAML file") if file_name.nil?
    credentials = fedora3_settings(file_name)
    namespace = "scholarsphere"
    logger.info "Auditing Fedora 3 at #{credentials[:url]}..."
    auditor = MigrateAuditFedora3.new(credentials[:url], credentials[:user], credentials[:password], namespace)
    MigrateAudit.f3_audit!(auditor)
  end  
end

