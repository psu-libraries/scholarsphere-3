# frozen_string_literal: true

# Mixin for saving ordered creators as Alias objects. Order is preserved via a second
# property that utilizes a local predicate. The order of the creator ids are stored
# as a delimited string.

module HasCreators
  extend ActiveSupport::Concern

  included do
    property :creators, predicate: ::RDF::Vocab::DC11.creator, class_name: 'Alias'
    alias_method :creator, :creators

    property :creator_list, predicate: PSUL.orderedCreators, multiple: false do |index|
      index.as :symbol
    end

    # @param [Hash,Array] values received from the form or input
    # Override property setter to save creators as Alias objects and retain their order
    # using a delimited string of ids.
    def creators=(values)
      alias_list = AliasList.new(values)
      self.creator_list = alias_list.ids.join('##')
      super(alias_list.uris)
    end

    # @return [Array<String>]
    # An ordered list of creator ids taken from the {creator_list} property
    def creator_ids
      return [] if creator_list.nil?
      creator_list.split(/##/)
    end

    # @return [Array<Alias>]
    # Use the ids in {creator_ids} to return an array of Alias objects in the correct order
    def creators
      creator_ids.map do |id|
        super.select { |m| m.id == id }.first
      end
    end
  end

  class AliasList
    attr_reader :values

    def initialize(parameters)
      @values = determine_values(parameters)
    end

    def determine_values(parameters)
      if parameters.is_a?(Hash)
        parameters.values
      else
        parameters
      end
    end

    def ids
      creator_aliases.map(&:id)
    end

    def uris
      creator_aliases.map(&:uri)
    end

    private

      def creator_aliases
        @creator_aliases ||= values.map { |v| AliasManagementService.call(v) }
      end
  end
end
