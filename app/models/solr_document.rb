# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class SolrDocument
  # Add Blacklight behaviors to the SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  # Method to return the ActiveFedora model
  def hydra_model
    Array(self[Solrizer.solr_name('active_fedora_model', Solrizer::Descriptor.new(:string, :stored, :indexed))]).first
  end

  def collections
    return nil if self[Solrizer.solr_name(:collection)].blank?
    collections_in = Array(self[Solrizer.solr_name(:collection)])
    collections = []
    collections_in.each do |pid|
      begin
        collections << Collection.load_instance_from_solr(pid)
      rescue
        logger.warn("Error loading Collection: #{pid} from solr")
      end
    end
    collections
  end

  private

    def ul_start_tags
      "<ul class='creator_list'>#{person_separator}<li>"
    end

    def ul_join_tags
      "</li>#{person_separator}<li> "
    end

    def ul_end_tags
      "</li></ul>"
    end

    def person_separator
      "<span class='glyphicon glyphicon-user'></span>"
    end
end
