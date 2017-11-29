# frozen_string_literal: true

class SearchBuilder < Sufia::CatalogSearchBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder

  self.default_processor_chain += [
    :add_access_controls_to_solr_params,
    :add_advanced_parse_q_to_solr,
    :show_works_or_works_that_contain_files
  ]

  # TODO: Remove this once projecthydra-labs/curation_concerns#724 is approved
  def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    return [] if ability.current_user.administrator?
    super
  end
end
