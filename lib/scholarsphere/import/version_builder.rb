# frozen_string_literal: true
# overriding the version importer because we did not really set up a great way for injecting
# new classes for the FileSet and Version below the GenericWork
module Import
  # Build all the versions of a file and add it to a file set
  class VersionBuilder < Sufia::Import::VersionBuilder
    # build versions based on the input
    #
    # @param file_set FileSet that will be modifed to include versions
    # @param Array[hash] generic_file_versions, each with the keys below
    #   @option :uri Link to content in Sufia 6 repository
    #   @option :label Version label
    #   @option :created date the version was created
    #
    def build(file_set, generic_file_versions)
      if file_set.id.nil?
        raise "FileSet must have an id before importing any versions"
      end
      sorted_versions = generic_file_versions.sort_by { |ver| ver[:created] }
      sorted_versions.each_with_index do |gf_version, index|
        filename_on_disk = create(file_set, gf_version)

        if index == (sorted_versions.count - 1)
          # characterize the current version
          characterize(file_set, filename_on_disk)
        else
          File.delete(filename_on_disk)
        end
      end
      # give the actual file its original file_name as opposed to the one we
      # used for convenience in this script
      file_set.original_file.file_name = file_set.label
      file_set.original_file.save
    end

    private

      def create(file_set, version)
        filename_on_disk = File.join Rails.root, "tmp/uploads", "#{file_set.id}_#{version[:label]}_#{file_set.label}"
        Rails.logger.debug "[IMPORT] Downloading #{version} to #{filename_on_disk}"

        source_request = sufia6_version_open_uri(version[:uri])
        uri = URI(version[:uri])
        Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request source_request do |response|
            File.open(filename_on_disk, 'wb') do |file_to_upload|
              response.read_body do |chunk|
                file_to_upload.write chunk
              end
            end
          end
        end

        # ...upload it...
        File.open(filename_on_disk, 'rb') do |file_to_upload|
          date_created = if f3_to_f4_migration_date?(version[:created])
                           file_set.date_uploaded
                         else
                           version[:created].to_datetime
                         end
          Sufia::Import::AddVersionToFileSet.call(file_set, file_to_upload, :original_file, date_created)
        end

        filename_on_disk
      end

      def sufia6_version_open_uri(content_uri)
        req = Net::HTTP::Get.new(content_uri)
        req.basic_auth sufia6_user, sufia6_password
        req
      end

      def characterize(file_set, filename_on_disk)
        ImportVersionJob.perform_later(file_set, filename_on_disk)
      end

      def f3_to_f4_migration_date?(date)
        date.starts_with?("2015-04-11")
      end
  end
end
