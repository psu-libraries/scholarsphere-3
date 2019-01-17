# frozen_string_literal: true

module Valkyrie
  module Persistence
    class AgentPersister < Valkyrie::Persistence::Postgres::Persister
      def ensure_multiple_values!(resource)
        if resource.is_a? Valkyrie::Agent
          true
        else
          super
        end
      end
    end
  end
end
