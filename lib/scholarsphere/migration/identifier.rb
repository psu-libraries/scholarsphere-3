# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Identifier
      attr_reader :identifiers

      # @param [Array<String>] list of all the identifiers for a work
      def initialize(identifiers)
        @identifiers = identifiers.to_a
      end

      # @return [String, nil] the doi for the work, if one is found
      def doi
        @doi ||= identifiers.select do |identifier|
          identifier.match(/18113|26207/)
        end.first
      end

      # @return [Array<String>]
      # @note Returns all the identifiers from the original work, minus the doi, if one is present
      def other
        identifiers - [doi]
      end
    end
  end
end
