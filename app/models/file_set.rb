# frozen_string_literal: true

class FileSet < ActiveFedora::Base
  include ::CurationConcerns::FileSetBehavior
  include Sufia::FileSetBehavior
  include AdditionalMetadata

  Hydra::Derivatives::FullTextExtract.output_file_service = PersistRemoteContainedOutputFileService

  def self.indexer
    FileSetIndexer
  end

  # @return [String, nil]
  # Copied from file_set_indexer for efficiency
  def file_format
    return unless mime_type.present? || format_label.present?

    formatted = format_mime_type_and_label
    formatted ||= format_mime_type
    formatted ||= format_label

    formatted
  end

  def format_mime_type_and_label
    return unless mime_type.present? && format_label.present?

    "#{format_mime_type} (#{format_label.join(', ')})"
  end

  def format_mime_type
    return if mime_type.blank?

    mime_type.split('/').last
  end
end
