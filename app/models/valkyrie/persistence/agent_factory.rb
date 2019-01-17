# frozen_string_literal: true

module Valkyrie
  module Persistence
    class AgentFactory < Valkyrie::Persistence::Postgres::ResourceFactory
      class << self
        # @param object [Valkyrie::Persistence::Postgres::ORM::Resource] AR
        #   record to be converted.
        # @return [Valkyrie::Resource] Model representation of the AR record.
        def to_resource(object:)
          if object.is_a? ::Agent
            agent = Valkyrie::Agent.new(object.attributes.with_indifferent_access)
            agent.alias_ids = object.alias_ids
            agent
          else
            super
          end
        end

        # @param resource [Valkyrie::Resource] Model to be converted to ActiveRecord.
        # @return [Valkyrie::Persistence::Postgres::ORM::Resource] ActiveRecord
        #   resource for the Valkyrie resource.
        def from_resource(resource:)
          if resource.is_a? Valkyrie::Agent
            hash = resource.to_h
            hash.delete(:internal_resource)
            hash.delete(:new_record)
            aliases = resource.aliases
            alias_ids = hash.delete(:alias_ids)
            valkyrie_id = hash.delete(:id)
            if valkyrie_id.present?
              fedora_agent = ::Agent.find(valkyrie_id.id)
              fedora_agent.update(hash.compact)
            else
              fedora_agent = ::Agent.new(hash.compact)
            end
            fedora_agent.alias_ids = alias_ids.map(&:id)
            fedora_agent.aliases = aliases if aliases.present?
            fedora_agent
          else
            super
          end
        end
      end
    end
  end
end
