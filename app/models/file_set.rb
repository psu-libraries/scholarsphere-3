# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  extend Deprecation
  include ::CurationConcerns::FileSetBehavior
  include Sufia::FileSetBehavior
  include AdditionalMetadata

  def self.indexer
    FileSetIndexer
  end

  def file_format
    Deprecation.warn(self, "Calling FileSet.file_format is deprecated. Use the value in its solr_document instead")
    return nil if mime_type.blank? && format_label.blank?
    return mime_type.split('/')[1] + " (" + format_label.join(", ") + ")" unless mime_type.blank? || format_label.blank?
    return mime_type.split('/')[1] unless mime_type.blank?
    format_label
  end
end
