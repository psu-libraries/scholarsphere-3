# frozen_string_literal: true
module SolrHelper
  def solr_field(name)
    Solrizer.solr_name(name, :stored_searchable, type: :string)
  end

  def contributor_facet
    Solrizer.solr_name("contributor", :facetable)
  end

  def index_work(object)
    allow(object).to receive(:bytes).and_return(0)
    ActiveFedora::SolrService.add(object.to_solr)
    ActiveFedora::SolrService.commit
  end

  def index_file_set(object)
    ActiveFedora::SolrService.add(object.to_solr)
    ActiveFedora::SolrService.commit
  end

  RSpec.configure do |config|
    config.include SolrHelper
  end
end
