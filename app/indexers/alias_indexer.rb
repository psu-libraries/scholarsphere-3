# frozen_string_literal: true

class AliasIndexer < Hydra::PCDM::ObjectIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      agent = object.agent
      next if agent.blank?
      aliases = object.other_aliases_for_my_agent
      name =  agent.display_name
      name = "#{name}, #{aliases.map(&:display_name).join(', ')}" if aliases.present?
      solr_doc[Solrizer.solr_name('agent_name')] = name
    end
  end
end
