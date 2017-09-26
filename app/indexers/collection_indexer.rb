# frozen_string_literal: true

class CollectionIndexer < CurationConcerns::CollectionIndexer
  self.thumbnail_path_service = Sufia::CollectionThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc.delete(Solrizer.solr_name(:file_size, CurationConcerns::FileSetIndexer::STORED_INTEGER))
      solr_doc[Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG)] = object.bytes
    end
  end
end
