# frozen_string_literal: true

module Migration
  class SolrWorkList < SolrObjectList
    alias_method :works, :objects

    def initialize
      super(GenericWork)
    end
  end
end
