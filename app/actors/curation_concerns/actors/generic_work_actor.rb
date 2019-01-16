# frozen_string_literal: true

# Changes the behavior of BaseActor#apply_save_data_to_curation_concern to re-assign the depositor
# based if the user is depositing on behalf of someone else.
#
# Additionally, this actor sets the title (again) because this preserves the order. It is
# not exactly clear why this happens, but it is a temporary solution until #948 and #949 are addressed.
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor
      def create(attributes)
        encoded_attributes = EncodedAttributeHash.new(attributes).encoded_hash
        capture_alias_errors do
          super(encoded_attributes)
        end
      end

      def update(attributes)
        update_depositor(attributes.delete(:depositor))
        encoded_attributes = EncodedAttributeHash.new(attributes).encoded_hash
        capture_alias_errors do
          super(encoded_attributes)
        end
      end

      protected

        # Overrides CurationConcerns::Actors::BaseActor to reassign the depositor
        # if the user is depositing on behalf of someone else.
        def apply_save_data_to_curation_concern(attributes)
          if attributes.fetch('on_behalf_of', nil).present?
            current_depositor = curation_concern.depositor
            new_depositor = ::User.find_by_user_key(attributes.fetch('on_behalf_of'))
            curation_concern.apply_depositor_metadata(new_depositor)
            curation_concern.edit_users = update_edit_users_for_curation_concern(current_depositor, new_depositor)
          end
          super
        end

        def capture_alias_errors
          yield
        rescue AliasManagementService::Error => error
          curation_concern.errors.add(:creator, :invalid, message: error.message)
          false
        end

        def update_depositor(new_depositor)
          return unless new_depositor && user.administrator?

          current_depositor = curation_concern.depositor
          curation_concern.depositor = new_depositor
          edit_users = curation_concern.edit_users
          edit_users.delete(current_depositor)
          edit_users << new_depositor
          curation_concern.edit_users = edit_users
        end

        def update_edit_users_for_curation_concern(current_depositor, new_depositor)
          edit_users = curation_concern.edit_users
          edit_users.delete(current_depositor)
          edit_users + [new_depositor, curation_concern.proxy_depositor]
          edit_users << user.user_key unless user.administrator?
          edit_users.uniq
        end

        class EncodedAttributeHash < ActiveSupport::HashWithIndifferentAccess
          def encoded_hash
            (keys.map(&:to_sym) & encodable_keys).map do |key|
              self[key] = encoded_value(self[key])
            end
            self
          end

          def encoded_value(value)
            if value.is_a?(Array)
              value.map { |v| EncodingService.call(v) }
            else
              EncodingService.call(value)
            end
          end

          def encodable_keys
            [:title, :description, :subtitle]
          end
        end
    end
  end
end
