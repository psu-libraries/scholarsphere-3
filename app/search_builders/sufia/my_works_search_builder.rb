# frozen_string_literal: true

# Added to allow for the My controller to show only things I have edit access to
class Sufia::MyWorksSearchBuilder < Sufia::SearchBuilder
  include Sufia::MySearchBuilderBehavior
  include CurationConcerns::FilterByType
  include BlacklightAdvancedSearch::AdvancedSearchBuilder

  self.default_processor_chain += [:show_only_resources_deposited_by_current_user,
                                   :add_advanced_parse_q_to_solr]

  def only_works?
    true
  end
end
