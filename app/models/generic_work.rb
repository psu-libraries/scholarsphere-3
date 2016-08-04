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
end
