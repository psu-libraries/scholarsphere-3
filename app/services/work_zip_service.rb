# frozen_string_literal: true

# A Service to take the contents of a work and convert it into a zip file.
#  It will take the original_file from each file set attached to the work.
#  This service will only include files the ability can read.
#  The zip file name will be returned from the call method.
#
# @example
#   work = GenericWork.find(id) # work with file sets attached
#
#   service = WorkZipService.new(work, current_ability)
#
#   zip_file_name = service.call
#
require 'zip'

class WorkZipService
  attr_reader :resource, :ability, :zipfile

  # Initialize the service
  #
  # @param [GenericWork]  resource work whose content will be zipped
  # @param [User|Ability] ability User|Ability who will have access to the zip
  # @param [String, Pathname] zip_directory location to store zip file on disk
  # @param [String] zipfile_name name of the zip file, defaults to the resource's title
  def initialize(resource, ability, zip_directory = 'tmp/', zipfile_name = nil)
    @resource = resource
    @ability = ability
    zipfile_name ||= resource.title.first.parameterize(separator: '_') + '.zip'
    @zipfile = ZipFile.new(Pathname.new(zip_directory).join(zipfile_name))
  end

  # create the zip file
  #
  # @return [String] full path to zip file
  def call
    create_zip if zipfile.stale?
    zipfile.file.to_s
  end

  private

    def create_zip
      Zip::File.open(zipfile.file, Zip::File::CREATE) do |zip_file|
        zip_manifest.each do |file|
          add_files_to_zip(zip_file, file)
        end
      end
    end

    def add_files_to_zip(zipfile, file_set)
      return unless add_to_zip?(file_set)

      zipfile.get_output_stream(file_set.title.first) do |outfile|
        location = FileSetDiskLocation.new(file_set)
        File.open(location.path).each { |buffer| outfile.write(buffer) }
      end
    end

    def zip_manifest
      resource.file_sets
    end

    def add_to_zip?(file_set)
      file_set.original_file.present? && (ability.can? :read, file_set.id)
    end
end
