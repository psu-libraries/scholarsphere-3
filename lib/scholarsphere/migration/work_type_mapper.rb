# frozen_string_literal: true

module Scholarsphere
  module Migration
    class WorkTypeMapper
      attr_reader :resource_types

      def initialize(resource_types: [])
        @resource_types = resource_types
      end

      def work_type
        return unless mapped_resource_type

        mapped_resource_type.downcase.gsub(/ /, '_')
      end

      private

        # @note more comprehensive mapping comming soon!
        def mapped_resource_type
          @mapped_resource_type ||= resource_types.first
        end
    end
  end
end
