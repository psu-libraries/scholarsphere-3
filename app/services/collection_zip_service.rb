# frozen_string_literal: true

# A service that takes the contents of a collection and creates a zip file containing
#   files for each work in the collection. Similar to WorkZipService,
#   this will only include files the user has read access to.
class CollectionZipService < WorkZipService
  private

    # @note overwrites existing files if the zip has been created previously
    def add_files_to_zip(zipfile, work)
      return unless ability.can? :read, work.id

      zipfile.add("#{work.title.first}.zip", WorkZipService.new(work, ability, zip_directory).call) do
        true
      end
    end

    def zip_manifest
      resource.members
    end
end
