# frozen_string_literal: true

module Valkyrie
  module Persistence
    class FedoraObjectPersister < Valkyrie::Persistence::Postgres::Persister
      def ensure_multiple_values!(resource)
        if resource.respond_to? :fedora_model
          true
        else
          super
        end
      end
    end
  end
end
