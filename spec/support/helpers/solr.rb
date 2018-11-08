# frozen_string_literal: true

module SolrHelper
  def solr_field(name)
    Solrizer.solr_name(name, :stored_searchable, type: :string)
  end

  def contributor_facet
    Solrizer.solr_name('contributor', :facetable)
  end

  def index_work(object, commit_now: true)
    allow(object).to receive(:bytes).and_return(0)
    ActiveFedora::SolrService.add(object.to_solr)
    ActiveFedora::SolrService.commit if commit_now
  end

  def index_works_and_collections(*objects)
    objects.each { |o| index_work(o) }
  end

  def index_file_set(object, commit_now: true)
    ActiveFedora::SolrService.add(object.to_solr)
    ActiveFedora::SolrService.commit if commit_now
  end

  def index_document(doc, commit_now: true)
    ActiveFedora::SolrService.add(doc)
    ActiveFedora::SolrService.commit if commit_now
  end

  RSpec.configure do |config|
    config.include SolrHelper
  end
end
