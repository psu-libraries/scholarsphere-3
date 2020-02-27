# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Resource < ApplicationRecord
      self.table_name = 'migration_resources'

      validates :pid, presence: true
      validates :model, presence: true

      def migrate(force: false)
        return if migrated? && !force

        update(started_at: DateTime.now)
        migration_update(ExportService.call(pid))
      rescue StandardError => exception
        migration_error(exception)
      end

      def message
        return {} if client_message.blank?

        HashWithIndifferentAccess.new(JSON.parse(client_message))
      end

      def migrated?
        !failed? && !blocked?
      end

      def failed?
        client_status != '200' && client_status != '201'
      end

      def blocked?
        exception.present?
      end

      def duration
        return 0 if completed_at.nil? || started_at.nil?

        completed_at - started_at
      end

      private

        def migration_update(result)
          update(
            client_status: result.status,
            client_message: result.body,
            exception: nil,
            error: nil,
            completed_at: DateTime.now
          )
        end

        def migration_error(exception)
          Rails.logger.error(exception.message)
          update(
            client_status: nil,
            client_message: nil,
            exception: exception.class,
            completed_at: DateTime.now
          )
        end
    end
  end
end
