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

  # Avoid deprecation warning in Blacklight::Document#initialize
  # Expects a hash-like object responding to :to_hash
  alias to_hash to_h

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

  # Remove this once https://github.com/projecthydra/curation_concerns/issues/1055 is resolved
  def file_size
    Array(self["file_size_lts"]).first
  end

  def bytes
    Array(self[Solrizer.solr_name(:bytes, CurationConcerns::CollectionIndexer::STORED_LONG)]).first
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
