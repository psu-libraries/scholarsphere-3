# frozen_string_literal: true

module Scholarsphere
  module Migration
    class FileSet
      attr_reader :file_set

      def initialize(file_set)
        @file_set = file_set
      end

      def metadata
        return unless path.exist?

        {
          file: path,
          deposited_at: DateValidator.call(file_set.date_uploaded || file_set.create_date)
        }
      end

      class NullPath
        def exist?
          false
        end
      end

      private

        def path
          @path ||= begin
                      path = path_for_location
                      Migration.log.info("Cannot find the file for file set #{file_set.id}") unless path.exist?
                      path
                    end
        end

        def path_for_location
          return NullPath.new if location.nil?

          Pathname.new(location.path)
        end

        def location
          FileSetDiskLocation.new(file_set)
        rescue StandardError
          nil
        end
    end
  end
end
