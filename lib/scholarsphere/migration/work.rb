# frozen_string_literal: true

module Scholarsphere
  module Migration
    class Work
      attr_reader :work

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
            visibility: embargo.visibility,
            noid: work.id,
            embargoed_until: embargo.release_date,
            work_type: WorkTypeMapper.new(resource_types: work.resource_type).work_type,
            deposited_at: DateValidator.call(work.date_uploaded || work.create_date),
            published_date: work.date_created.join(', '),
            description: work.description.join(' ')
          )
      end

      def permissions
        @permissions ||= Permissions.new(work).attributes
      end

      def files
        @files ||= file_sets.map do |file_set|
          Migration::FileSet.new(file_set).metadata
        end.compact
      end

      def depositor
        @depositor ||= Depositor.new(login: work.depositor).metadata
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

        def embargo
          @embargo ||= Embargo.new(work: work, file_sets: file_sets)
        end

        # @note Terms that can be copied directly from the original work to the new one without any "translation"
        def direct_terms
          [
            :subtitle,
            :rights,
            :version_name,
            :keyword,
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

        def external_file_path(file_set)
          location = FileSetDiskLocation.new(file_set)
          path = Pathname.new(location.path)
          raise Error, "FileSet for #{path.basename} does not exist" unless path.exist?

          path
        end

        def file_sets
          @file_sets ||= work.file_sets
        end
    end
  end
end
