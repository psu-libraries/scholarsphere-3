# frozen_string_literal: true
module Export
  class CollectionConverter < Sufia::Export::CollectionConverter
    # Create an instance of a Collection converter containing all the metadata for json export
    #
    # @param [Collection] collection to be converted for export
    def initialize(collection)
      super
      @depositor = collection.depositor
    end
  end
end
