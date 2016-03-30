# frozen_string_literal: true
module SolrHelper
  def solr_field(name)
    Solrizer.solr_name(name, :stored_searchable, type: :string)
  end

  def contributor_facet
    Solrizer.solr_name("contributor", :facetable)
  end

  RSpec.configure do |config|
    config.include SolrHelper
  end
end
