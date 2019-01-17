# frozen_string_literal: true

module Valkyrie
  module Persistence
    class AgentAdapter
      def persister
        Valkyrie::Persistence::AgentPersister.new(adapter: self)
      end

      # @return [Class] {Valkyrie::Persistence::Postgres::QueryService}
      def query_service
        @query_service ||= Valkyrie::Persistence::AgentQueryService.new(adapter: self)
      end

      # @return [Class] {Valkyrie::Persistence::Postgres::ResourceFactory}
      def resource_factory
        Valkyrie::Persistence::AgentFactory
      end
    end
  end
end
