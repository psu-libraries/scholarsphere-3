# frozen_string_literal: true

module RenderConstraintsHelper
  include Blacklight::RenderConstraintsHelperBehavior

  ##
  # Override Blacklight to allow for blank values in facets.
  #    This is required for out blank resource types
  #
  # Render a single facet's constraint
  # @param [String] facet field
  # @param [Array<String>] values selected facet values
  # @param [Blacklight::SearchState] path query parameters
  # @return [String]
  def render_filter_element(facet, values, path)
    facet_config = facet_configuration_for_field(facet)

    safe_join(Array(values).map do |val|
      render_constraint_element(facet_field_label(facet_config.key),
                                facet_display_value(facet, val),
                                remove: search_action_path(path.remove_facet_params(facet, val)),
                                classes: ['filter', 'filter-' + facet.parameterize])
    end, "\n")
  end
end
