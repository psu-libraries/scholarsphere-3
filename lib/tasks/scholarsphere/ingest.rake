# frozen_string_literal: true

namespace :scholarsphere do
  desc 'Ingest files from the network directory'
  task ingest: :environment do
    ScholarSphere::Application.config.network_ingest_directory.children.map do |work|
      if work.directory?
        NetworkIngestService.call(work)
      end
    end
  end
end
