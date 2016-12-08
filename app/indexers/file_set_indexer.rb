# frozen_string_literal: true
# We should be able to remove this once projecthydra/curation_concerns#1117 is closed
class FileSetIndexer < CurationConcerns::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc.delete(Solrizer.solr_name(:file_size, CurationConcerns::FileSetIndexer::STORED_INTEGER))
      solr_doc[Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG)] = object.file_size[0]
    end
  end
end
