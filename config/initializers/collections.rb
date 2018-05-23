# frozen_string_literal: true

# Overrides Curation Concerns to display more than 100 rows for Collections in the Work relationship tab
begin
  ScholarSphere::Application.config.max_collection_query_rows = Collection.count + 1000
rescue RSolr::Error::ConnectionRefused
  ScholarSphere::Application.config.max_collection_query_rows = 500000
end
# CurationConcerns::CollectionsService.list_search_builder_class = CollectionSearchBuilder
