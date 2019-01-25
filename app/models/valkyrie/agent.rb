# frozen_string_literal: true

module Valkyrie
  class Agent < Valkyrie::Resource
    attr_reader :aliases

    attribute :id, Valkyrie::Types::ID.optional
    attribute :given_name, Valkyrie::Types::String
    attribute :sur_name, Valkyrie::Types::String
    attribute :psu_id, Valkyrie::Types::String
    attribute :email, Valkyrie::Types::String
    attribute :orcid_id, Valkyrie::Types::String

    attribute :alias_ids, Valkyrie::Types::Set.of(Valkyrie::Types::ID)

    def fedora_model
      ::Agent
    end

    def aliases=(aliases)
      @aliases = aliases.map { |alias_hash| Alias.new(alias_hash) }
    end

    def display_name
      "#{given_name} #{sur_name}"
    end
  end
end
