# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Resource < ApplicationRecord
      include ActionView::Helpers::TextHelper

      self.table_name = 'migration_resources'

      validates :pid, presence: true
      validates :model, presence: true

      def migrate(force: false)
        return if migrated? && !force

        migration_update(ExportService.call(pid))
      rescue StandardError => exception
        migration_error(exception)
      end

      def message
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

      private

        def migration_update(result)
          update(
            client_status: result.status,
            client_message: result.body,
            exception: nil,
            error: nil
          )
        end

        def migration_error(exception)
          update(
            client_status: nil,
            client_message: nil,
            exception: exception.class,
            error: truncate(exception.message, length: 255)
          )
        end
    end
  end
end
