# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Collection
      attr_reader :collection

      # @param [Collection] the thing we want to migrate
      def initialize(collection)
        @collection = collection
      end

      def metadata
        collection_attributes
          .slice(*direct_terms)
          .merge(
            title: migrated_title,
            creator_aliases_attributes: creators,
            noid: collection.id,
            deposited_at: DateValidator.call(collection.create_date),
            published_date: collection.date_created.join(', ')
          )
      end

      def permissions
        @permissions ||= Permissions.new(collection).attributes
      end

      def depositor
        @depositor ||= Depositor.new(login: collection.depositor).metadata
      end

      def work_noids
        @work_noids ||= collection.work_ids
      end

      private

        def collection_attributes
          @collection_attributes ||= HashWithIndifferentAccess.new(collection.attributes)
        end

        def migrated_title
          raise Error, 'multiple titles found' if collection.title.count > 1

          collection.title.first
        end

        def creators
          collection.creators.map do |creator|
            Creator.new(creator).metadata
          end
        end

        # @note Terms that can be copied directly from the original collection to the new one without any "translation"
        def direct_terms
          [
            :subtitle,
            :rights,
            :version_name,
            :keywords,
            :description,
            :resource_type,
            :contributor,
            :publisher,
            :subject,
            :language,
            :identifier,
            :based_near,
            :related_url,
            :source
          ]
        end
    end
  end
end
