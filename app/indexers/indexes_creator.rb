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
      facet_names = object.creators.map { |c| build_facet(c) }
      solr_doc[Solrizer.solr_name('creator_name', :facetable)] = facet_names
      solr_doc[Solrizer.solr_name('creator_facet_name', :stored_searchable)] = facet_names
      solr_doc[Solrizer.solr_name('creator_name', :stored_searchable)] = creator_names
    end

    def build_facet(creator)
      return creator.display_name if creator.agent.nil?
      "#{creator.agent.given_name} #{creator.agent.sur_name}".strip.titleize.gsub(/[\.\,]/, '')
    end
end
