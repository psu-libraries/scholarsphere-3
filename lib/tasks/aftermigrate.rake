require 'action_view'
require 'blacklight/solr_helper'
require 'rainbow'

include ActionView::Helpers::NumberHelper
include Blacklight::SolrHelper

namespace :aftermigrate do

  F3AuditRow = Struct.new("F3Audit", :f3_pid, :f3_model)

  def logger
    Rails.logger
  end

  def fake_f3_data(file_name)
    f3_data = []
    line_number = 0
    File.open(file_name).read.each_line do |raw_line|
      line_number += 1
      next if line_number == 1
      break if line_number == 100
      line = raw_line.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      tokens = line.split("\t")
      f3_pid = tokens[1]
      f3_model = tokens[2]
      f3_data.push(F3AuditRow.new(f3_pid, f3_model))
    end
    f3_data
  end

  # Runs a test of the audit using a tab delimited text file as its 
  # input. This method does not update the migrate_audit SQL table,
  # instead the results are show in STDOUT.
  desc "Runs a test of the audit using data from a tab delimited text file"
  task "f4_test", [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    abort("No data file specified") if file_name.nil?
    credentials = ActiveFedora.fedora_config.credentials
    fedora_url = credentials[:url] + credentials[:base_path]
    audit = MigrateAuditFedora4.new(fedora_url, credentials[:user], credentials[:password])
    puts "Reading data from #{file_name}..."
    f3_data = fake_f3_data(file_name)
    puts "Validating #{f3_data.count} objects..."
    results = audit.audit(f3_data)
    results.each do |result|
      puts result
    end
  end

  # Udates record in migrate_audit SQL table with the information from 
  # the matching Fedora 4 objects.
  desc "Updates migrate_audit SQL table with information from Fedora 4 objects"
  task f4_audit: :environment do |cmd, args|
    credentials = ActiveFedora.fedora_config.credentials
    fedora_url = credentials[:url] + credentials[:base_path]
    MigrateAudit.f4_audit(fedora_url, credentials[:user], credentials[:password])
  end

end

