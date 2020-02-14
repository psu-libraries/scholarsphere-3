# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Work
      attr_reader :work

      delegate :depositor, to: :work

      # @param [GenericWork] the thing we want to migrate
      def initialize(work)
        @work = work
      end

      def metadata
        work_attributes
          .slice(*direct_terms)
          .merge(
            title: migrated_title,
            creator_aliases_attributes: creators,
            visibility: work.visibility
          )
      end

      def permissions
        @permissions ||= HashWithIndifferentAccess.new(permissions_hash)
      end

      # @return [Array<Pathname>]
      def files
        external_files.map do |location|
          path = Pathname.new(location.path)
          raise Error, "FileSet for #{path.basename} does not exist" unless path.exist?

          path
        end
      end

      private

        def work_attributes
          @work_attributes ||= HashWithIndifferentAccess.new(work.attributes)
        end

        def migrated_title
          raise Error, 'multiple titles found' if work.title.count > 1

          work.title.first
        end

        def creators
          work.creators.map do |creator|
            Creator.new(creator).metadata
          end
        end

        # @note Terms that can be copied directly from the original work to the new one without any "translation"
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
            :published_date,
            :subject,
            :language,
            :identifier,
            :based_near,
            :related_url,
            :source
          ]
        end

        def permissions_hash
          {
            edit_users: work.edit_users,
            edit_groups: work.edit_groups,
            read_users: work.read_users,
            read_groups: work.read_groups
          }
        end

        def external_files
          @external_files ||= work.file_sets.map { |file_set| FileSetDiskLocation.new(file_set) }
        end
    end
  end
end
