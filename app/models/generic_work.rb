# frozen_string_literal: true
class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  include ShareNotify::Metadata
  include AdditionalMetadata

  self.human_readable_type = 'Work'

  validates :title, presence: { message: 'Your work must have a title.' }

  def self.indexer
    WorkIndexer
  end

  # Compute the sum of each file in the work using Solr to
  # avoid having to access Fedora
  #
  # @return [Fixnum] size of work in bytes
  # @raise [RuntimeError] unsaved record does not exist in solr
  def bytes
    return 0 if member_ids.count == 0
    raise "Work must be saved to query for bytes" if new_record?
    sizes = member_ids.collect { |fs_id| file_set_size(fs_id) }
    sizes.compact.map { |fs| fs[file_size_field] }.reduce(0, :+)
  end

  private

    def file_set_size(fs_id)
      result = ActiveFedora::Base.search_by_id(fs_id.to_s, fl: file_size_field.to_s)
      return if result.empty?
      result
    end

    # Field name to look up when locating the size of each file in Solr.
    def file_size_field
      Solrizer.solr_name(:file_size, CurationConcerns::FileSetIndexer::STORED_INTEGER)
    end
end
