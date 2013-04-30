# -*- encoding : utf-8 -*-
class SolrDocument
  # Add Blacklight behaviors to the SolrDocument
  include Blacklight::Solr::Document
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  # Method to return the ActiveFedora model
  def hydra_model
    Array(self[Solrizer.solr_name('active_fedora_model', Solrizer::Descriptor.new(:string, :stored, :indexed))]).first
  end
end
