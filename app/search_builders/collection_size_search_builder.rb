# frozen_string_literal: true
class CollectionSizeSearchBuilder < Blacklight::Solr::SearchBuilder
  include Hydra::Collections::SearchBehaviors
end
