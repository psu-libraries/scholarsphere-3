# frozen_string_literal: true

module Scholarsphere
  module Migration
    class ExportService
      def self.call(id)
        resource = ActiveFedora::Base.find(id)

        new(resource).export
      end

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def export
        case resource
        when ::GenericWork
          export_work
        when ::Collection
          export_collection
        else
          raise ArgumentError, "can't export #{resource.class}"
        end
      end

      def export_work
        export = Scholarsphere::Migration::Work.new(resource)

        ingest = Scholarsphere::Client::Ingest.new(
          metadata: export.metadata,
          files: export.files,
          depositor: export.depositor,
          permissions: export.permissions
        )

        ingest.publish
      end

      def export_collection
        export = Scholarsphere::Migration::Collection.new(resource)

        collection = Scholarsphere::Client::Collection.new(
          metadata: export.metadata,
          depositor: export.depositor,
          permissions: export.permissions,
          work_noids: export.work_noids
        )

        collection.create
      end
    end
  end
end
