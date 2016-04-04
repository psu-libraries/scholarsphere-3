# frozen_string_literal: true

# This class is used to consolidate Collection metadata in a way that
# can be easily exported to JSON.
module Export
  class CollectionMetadataExport
    attr_accessor :id, :title, :depositor, :description, :creator, :members

    def initialize(coll)
      @id = coll.id
      @title = coll.title
      @description = coll.description
      @creator = coll.creator.map { |c| c }
      @members = coll.members.map(&:id)
    end

    def to_json(pretty = false)
      return super unless pretty
      JSON.pretty_generate(JSON.parse(to_json))
    end
  end
end
