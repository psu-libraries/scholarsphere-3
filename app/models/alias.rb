# frozen_string_literal: true

class Alias < ActiveFedora::Base
  include Hydra::PCDM::ObjectBehavior

  self.indexer = AliasIndexer

  def valkyrie_resource
    Valkyrie::Alias
  end

  belongs_to :agent, class_name: 'Agent', predicate: ::RDF::Vocab::FOAF.name

  after_save :update_alias_indexes

  property :display_name, predicate: ::RDF::Vocab::FOAF.nick, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  def update_alias_indexes
    others_aliases = other_aliases_for_my_agent
    return if others_aliases.blank? || previous_changes.exclude?('display_name')

    others_aliases.each(&:update_index)
  end

  def other_aliases_for_my_agent
    return if agent.blank?

    agent.reload.aliases.reject { |current_alias| current_alias.id == id }
  end

  def attributes_including_linked_ids
    attributes.merge(agent_id: agent_id).with_indifferent_access
  end
end
