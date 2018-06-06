# frozen_string_literal: true

class CollectionSearchBuilder < CurationConcerns::CollectionSearchBuilder
  # Defines which search_params_logic should be used when searching for Collections
  def initialize(*)
    super
    @rows = ScholarSphere::Application.config.max_collection_query_rows
  end
end
