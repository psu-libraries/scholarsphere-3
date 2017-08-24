# frozen_string_literal: true

# Changes the behavior of BaseActor#apply_save_data_to_curation_concern to re-assign the depositor
# based if the user is depositing on behalf of someone else.
#
# Additionally, this actor sets the title and creator (again) because this preserves the order. It is
# not exactly clear why this happens, but it is a temporary solution until #948 and #949 are addressed.
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor

      # >> p attributes
      # => {"title"=>["Title"], "contributor"=>[], "description"=>["abs"], "keyword"=>["asdf"], "rights"=>["https://creativecommons.org/licenses/by/4.0/"], "publisher"=>[], "date_created"=>[], "subject"=>[], "language"=>[], "identifier"=>[], "based_near"=>[], "related_url"=>[], "visibility"=>"open", "source"=>[], "resource_type"=>["Article"], "subtitle"=>"", 
      # "creators"=>{"0"=>{"first_name"=>"first name 000", "last_name"=>"last name 000"}, "1"=>{"first_name"=>"first name 111", "last_name"=>"last name 111"}},
      # "remote_files"=>[], "uploaded_files"=>["43"]}

      def create(attributes)
        # 999 extract the creators and find or create matching Person records
# byebug
        preserve_title_and_creator_order(attributes)
        super
      end

      protected

        # Remove this method once #948 and #949 are resolved.
        def preserve_title_and_creator_order(attributes)
          # 999
          # curation_concern.creator = attributes[:creator]
          # curation_concern.save
          curation_concern.title = attributes[:title]
        end

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
    end
  end
end
