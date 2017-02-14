# frozen_string_literal: true
# Cleans up existing fields in the solr document before it is sent on for indexing
class SolrDocumentGroomer
  attr_reader :document

  # @param [SolrDocument, Hash]
  # @return [SolrDocument, Hash]
  def self.call(document)
    new(document).groom
  end

  def initialize(document)
    @document = document
  end

  def groom
    FieldConfigurator.facet_fields.each do |field, config|
      cleaned_fields = FacetValueCleaningService.call(document.fetch(Solrizer.solr_name(field.to_s, :facetable), []), config)
      document[Solrizer.solr_name(field.to_s, :facetable)] = cleaned_fields
    end
  end
end
