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

  def fake_f3_data
    f3_data = []
    f3_data.push(F3AuditRow.new("scholarsphere:fb1248f3-929a-4a20-be1c-ed1ec1db3f9c", "info:fedora/afmodel:XyzBatch"))
    f3_data.push(F3AuditRow.new("scholarsphere:9162d93a-ac54-4598-a143-016c19e3d51c", "info:fedora/afmodel:GenericFile"))
    f3_data.push(F3AuditRow.new("scholarsphere:000000018", "info:fedora/afmodel:GenericFile"))
    f3_data
  end

  desc "Test"
  task f4_test: :environment do |cmd, args|
    credentials = ActiveFedora.fedora_config.credentials
    fedora_url = credentials[:url] + credentials[:base_path]
    audit = MigrateAuditFedora4.new(fedora_url, credentials[:user], credentials[:password])
    results = audit.audit(fake_f3_data)
    results.each do |result|
      puts result
    end
  end

  # This tasks updates migrate_audit SQL table with the information for the matching Fedora 4 objects.
  desc "Updates migrate_audit SQL table with information from Fedora 4 objects"
  task f4_audit: :environment do |cmd, args|
    credentials = ActiveFedora.fedora_config.credentials
    fedora_url = credentials[:url] + credentials[:base_path]
    MigrateAudit.f4_audit(fedora_url, credentials[:user], credentials[:password])
  end

end

