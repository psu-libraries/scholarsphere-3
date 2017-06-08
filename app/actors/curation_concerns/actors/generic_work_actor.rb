# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor
      # Override CurationConcerns to pass attributes to apply_creation_data_to_curation_concern
      # and re-apply creator to ensure order is correct.
      def create(attributes)
        @cloud_resources = attributes.delete(:cloud_resources.to_s)
        apply_creation_data_to_curation_concern(attributes)
        apply_save_data_to_curation_concern(attributes)
        next_actor.create(attributes) && save && run_callbacks(:after_create_concern)

        # TODO: When we move to RDF 2 we will need to remove this code.
        # Retains order in title and creator while we are on RDF 1.9.
        # The interim call to .save is needed, otherwise, resetting the order of titles
        # changes the order of the creators as well!
        curation_concern.creator = attributes[:creator]
        curation_concern.save
        curation_concern.title = attributes[:title]
      end

      protected

        def apply_creation_data_to_curation_concern(attributes)
          apply_depositor_metadata(attributes)
          apply_deposit_date
        end

        def apply_depositor_metadata(attributes)
          if attributes.key?("on_behalf_of")
            depositor = ::User.find_by_user_key(attributes.fetch("on_behalf_of"))
            curation_concern.apply_depositor_metadata(depositor)
            curation_concern.edit_users += [depositor, user.user_key]
          else
            curation_concern.apply_depositor_metadata(user.user_key)
            curation_concern.edit_users += [user.user_key]
          end
        end
    end
  end
end
