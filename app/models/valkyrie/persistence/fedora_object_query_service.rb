# frozen_string_literal: true

module Valkyrie
  module Persistence
    class FedoraObjectQueryService < Valkyrie::Persistence::Postgres::QueryService
      def find_by(id:)
        super
      rescue Valkyrie::Persistence::ObjectNotFoundError => e
        find_in_fedora(id: id, original_error: e)
      end

      private

        def find_in_fedora(id:, original_error:)
          fedora_id = id
          fedora_id = fedora_id.id if fedora_id.is_a? Valkyrie::ID
          resource_factory.to_resource(object: ActiveFedora::Base.find(fedora_id))
        rescue ActiveFedora::ObjectNotFoundError
          raise(original_error)
        end
    end
  end
end
