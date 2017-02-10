# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::CurationConcerns::CollectionBehavior
  include CurationConcerns::BasicMetadata
  self.indexer = CollectionIndexer

  private

    # Field name to look up when locating the size of each file in Solr.
    def file_size_field
      Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG)
    end
end
