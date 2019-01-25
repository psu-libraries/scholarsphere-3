# frozen_string_literal: true

module Valkyrie
  module Persistence
    class FedoraObjectFactory < Valkyrie::Persistence::Postgres::ResourceFactory
      class << self
        # @param object [Valkyrie::Persistence::Postgres::ORM::Resource] AR
        #   record to be converted.
        # @return [Valkyrie::Resource] Model representation of the AR record.
        def to_resource(object:)
          if object.respond_to? :attributes_including_linked_ids
            object.valkyrie_resource.new(object.attributes_including_linked_ids)
          else
            super
          end
        end

        # @param resource [Valkyrie::Resource] Model to be converted to ActiveRecord.
        # @return [Valkyrie::Persistence::Postgres::ORM::Resource] ActiveRecord
        #   resource for the Valkyrie resource.
        def from_resource(resource:)
          return super(resource: resource) unless resource.respond_to?(:fedora_model)

          if resource.is_a? Valkyrie::Agent
            translate_resource(resource, :alias_ids) do |fedora_object, linked_data|
              fedora_object.alias_ids = linked_data.map(&:id)
              fedora_object.aliases = resource.aliases.map { |valkyrie_alias| from_resource(resource: valkyrie_alias) } if resource.aliases.present?
              fedora_object
            end
          elsif resource.is_a? Valkyrie::Alias
            translate_resource(resource, :agent_id) do |fedora_object, linked_data|
              fedora_object.agent_id = linked_data
              fedora_object.agent = from_resource(resource: resource.agent) if resource.agent.present?
              fedora_object
            end
          end
        end

          private

            def translate_resource(resource, linked_resource_key, &block)
              hash = resource.to_h
              hash.delete(:internal_resource)
              hash.delete(:new_record)
              valkyrie_id = hash.delete(:id)
              linked_resource_info = hash.delete(linked_resource_key)
              if valkyrie_id.present?
                fedora_agent = resource.fedora_model.find(valkyrie_id.id)
                fedora_agent.update(hash.compact)
              else
                fedora_agent = resource.fedora_model.new(hash.compact)
              end
              block.yield(fedora_agent, linked_resource_info)
            end
        end
    end
  end
end
