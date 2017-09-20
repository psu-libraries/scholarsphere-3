# frozen_string_literal: true

module IndexesCreator
  include ActiveSupport::Concern

  def generate_solr_document
    super.tap do |solr_doc|
      index_creator(solr_doc)
    end
  end

  private

    def index_creator(solr_doc)
      creator_names = object.creators.map(&:display_name)
      solr_doc[Solrizer.solr_name('creator_name', :facetable)] = creator_names
      solr_doc[Solrizer.solr_name('creator_name', :stored_searchable)] = creator_names
    end
end
