require 'action_view'
require 'blacklight/solr_helper'
require 'rainbow'

include ActionView::Helpers::NumberHelper
include Blacklight::SolrHelper

namespace :aftermigrate do

  def logger
    Rails.logger
  end

  # Updates the records in migrate_audit SQL table with the information from 
  # the matching Fedora 4 objects.
  # This task must be run from a version of the code that targets Fedora 4
  # (mostly because it expects to find the settings for a Fedora 4 repo
  # in the ActiveFedora.fedora_config.credentials object.)
  desc "Updates migrate_audit SQL table with information from Fedora 4 objects"
  task f4_audit: :environment do |cmd, args|
    credentials = ActiveFedora.fedora_config.credentials
    fedora_url = credentials[:url] + credentials[:base_path]
    auditor = MigrateAuditFedora4.new(fedora_url, credentials[:user], credentials[:password])
    MigrateAudit.f4_audit(auditor)
  end

end

