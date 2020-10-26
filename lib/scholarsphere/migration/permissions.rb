# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Permissions
      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def attributes
        HashWithIndifferentAccess.new(permissions_hash)
      end

      private

        def permissions_hash
          {
            edit_users: resource.edit_users - blacklisted_users,
            edit_groups: resource.edit_groups - blacklisted_groups,
            read_users: resource.read_users - blacklisted_users,
            read_groups: resource.read_groups - blacklisted_groups
          }
        end

        def blacklisted_users
          [resource.depositor]
        end

        # @note Remove any visibility groups. These are handled with the visibility attribute.
        def blacklisted_groups
          [
            Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC,
            Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
          ]
        end
    end
  end
end
