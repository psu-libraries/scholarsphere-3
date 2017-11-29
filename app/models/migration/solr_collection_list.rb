# frozen_string_literal: true

module Migration
  class SolrCollectionList < SolrObjectList
    alias_method :collections, :objects

    def initialize
      super(Collection)
    end
  end
end
