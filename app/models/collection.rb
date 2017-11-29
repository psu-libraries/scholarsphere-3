# frozen_string_literal: true

class Collection < ActiveFedora::Base
  include ::CurationConcerns::CollectionBehavior
  include ::BasicMetadata
  include HasCreators
  self.indexer = CollectionIndexer

  property :subtitle, predicate: ::RDF::Vocab::EBUCore.subtitle, multiple: false do |index|
    index.as :stored_searchable
  end

  def private_access?
    super unless new_record?
    false
  end

  def open_access?
    super unless new_record?
    true
  end

  private

    # Field name to look up when locating the size of each file in Solr.
    def file_size_field
      Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG)
    end
end
