# frozen_string_literal: true

module My
  class SharesController < MyController
    field_config = FieldConfigurator.common_fields[:has_model]
    solr_type = field_config.opts.fetch(:solr_type, :facetable)
    blacklight_config.add_facet_field solr_name(:has_model, solr_type), label: field_config.label, limit: 5,
                                                                        helper_method: field_config.opts[:helper_method]

    def search_builder_class
      Sufia::MySharesSearchBuilder
    end

    def index
      super
      @selected_tab = 'shared'
    end

    protected

      def search_action_url(*args)
        sufia.dashboard_shares_url(*args)
      end

      # The url of the "more" link for additional facet values
      def search_facet_path(args = {})
        sufia.dashboard_shares_facet_path(args[:id])
      end
  end
end
