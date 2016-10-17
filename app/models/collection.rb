# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::CurationConcerns::CollectionBehavior
  include CurationConcerns::BasicMetadata
  self.indexer = Sufia::CollectionIndexer
end
