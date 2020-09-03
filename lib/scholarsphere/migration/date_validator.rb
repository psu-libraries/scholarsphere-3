# frozen_string_literal: true

module Scholarsphere
  module Migration
    class DateValidator
      def self.call(date)
        return if date.nil?
        return date if date.is_a?(DateTime)

        DateTime.parse(date)
      end
    end
  end
end
