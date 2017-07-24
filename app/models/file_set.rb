# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  include ::CurationConcerns::FileSetBehavior
  include Sufia::FileSetBehavior
  include AdditionalMetadata

  def self.indexer
    FileSetIndexer
  end

  # @return [String, nil]
  # Field value is constructed at index time in CurationConcerns::FileSetIndexer
  def file_format
    to_solr.fetch('file_format_sim', nil)
  end
end
