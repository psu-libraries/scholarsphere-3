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
        capture_alias_errors do
          super
        end
      end

      def update(attributes)
        capture_alias_errors do
          super
        end
      end

      protected

        # Overrides CurationConcerns::Actors::BaseActor to reassign the depositor
        # if the user is depositing on behalf of someone else.
        def apply_save_data_to_curation_concern(attributes)
          if attributes.fetch('on_behalf_of', nil).present?
            depositor = ::User.find_by_user_key(attributes.fetch('on_behalf_of'))
            curation_concern.apply_depositor_metadata(depositor)
            curation_concern.edit_users += [depositor, user.user_key]
          end
          super
        end

        def capture_alias_errors
          yield
        rescue AliasManagementService::Error => error
          curation_concern.errors.add(:creator, :invalid, message: error.message)
          return false
        end
    end
  end
end
