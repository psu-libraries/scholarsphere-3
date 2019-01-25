# frozen_string_literal: true

module Valkyrie
  class Alias < Valkyrie::Resource
    attr_reader :agent

    attribute :id, Valkyrie::Types::ID.optional
    attribute :agent_id, Valkyrie::Types::ID.optional
    attribute :display_name, Valkyrie::Types::String

    def fedora_model
      ::Alias
    end

    def agent=(agent_or_hash)
      @agent = if agent.is_a? Hash
                 Agent.new(agent_or_hash)
               else
                 agent_or_hash
               end
    end
  end
end
