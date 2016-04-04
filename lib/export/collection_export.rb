# frozen_string_literal: true
module Export
  class CollectionExport
    attr_accessor :id, :title

    def initialize(coll)
      @id = coll.id
      @title = coll.title
    end

    def to_json(pretty = false)
      return super unless pretty
      JSON.pretty_generate(JSON.parse(to_json))
    end
  end
end
