# frozen_string_literal: true

class AliasIndexer < Hydra::PCDM::ObjectIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      agent = object.agent
      next if agent.blank?
      solr_doc[Solrizer.solr_name('agent_name')] = "#{agent.given_name} #{agent.sur_name}"
    end
  end
end
