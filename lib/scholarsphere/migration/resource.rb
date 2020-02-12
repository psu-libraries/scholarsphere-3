# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Resource < ApplicationRecord
      self.table_name = 'migration_resources'

      validates :pid, presence: true
      validates :model, presence: true

      def migrate(force: false)
        return if migrated? && !force

        result = ExportService.call(pid)
        update(client_status: result.status, client_message: result.body)
      rescue StandardError => exception
        update(exception: exception.class, error: exception.message)
      end

      def message
        HashWithIndifferentAccess.new(JSON.parse(client_message))
      end

      def migrated?
        !failed? && !blocked?
      end

      def failed?
        client_status != '200'
      end

      def blocked?
        exception.present?
      end
    end
  end
end
