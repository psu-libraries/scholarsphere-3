# frozen_string_literal: true

module Scholarsphere
  module Migration
    class ExportService
      def self.call(id)
        work = ActiveFedora::Base.find(id)

        export_work = Work.new(work)

        ingest = Scholarsphere::Client::Ingest.new(
          metadata: export_work.metadata,
          files: export_work.files,
          depositor: export_work.depositor,
          permissions: export_work.permissions
        )

        ingest.publish
      end
    end
  end
end
