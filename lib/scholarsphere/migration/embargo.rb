# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Embargo
      attr_reader :work, :file_sets

      def initialize(work:, file_sets:)
        @work = work
        @file_sets = file_sets
      end

      def embargoed?
        work.under_embargo? || file_sets.any?(&:under_embargo?)
      end

      def visibility
        return work.visibility unless embargoed?

        latest.visibility_after_embargo
      end

      def release_date
        return unless embargoed?

        latest.embargo_release_date.iso8601
      end

      private

        def latest
          if file_sets.any?(&:under_embargo?)
            latest_file_embargo
          else
            work.embargo
          end
        end

        def latest_file_embargo
          file_sets
            .select(&:under_embargo?)
            .max_by(&:embargo_release_date)
            .embargo
        end
    end
  end
end
