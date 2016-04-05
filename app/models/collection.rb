# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::CurationConcerns::CollectionBehavior
  include Sufia::CollectionBehavior
  include CurationConcerns::BasicMetadata
end
