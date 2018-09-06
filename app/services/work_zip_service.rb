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
  attr_reader :resource, :ability, :zip_directory

  # Initialize the service
  #
  # @param [GenericWork]  resource       work whose content will be zipped
  # @param [User|Ability] ability        User|Ability who will have access to the zip
  # @param [String]       zip_directory  Location to store zip file on disk
  def initialize(resource, ability, zip_directory = 'tmp/')
    @resource = resource
    @ability = ability
    @zip_directory = zip_directory
  end

  # create the zip file
  #
  # @return [String] zip file name
  def call
    zipfile_name = File.join(zip_directory, "#{resource.title.first.parameterize('_')}.zip")

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zip_file|
      zip_manifest.each do |file|
        add_files_to_zip(zip_file, file)
      end
    end
    zipfile_name
  end

  private

    def add_files_to_zip(zipfile, file_set)
      if ENV['REPOSITORY_EXTERNAL_FILES'] == 'true'
        add_external_files_to_zip(zipfile, file_set)
      else
        add_internal_files_to_zip(zipfile, file_set)
      end
    end

    def zip_manifest
      resource.file_sets
    end

    def add_internal_files_to_zip(zipfile, file_set)
      return unless add_to_zip?(file_set)
      zipfile.get_output_stream(file_set.title.first) do |outfile|
        file_set.original_file.stream.each { |buffer| outfile.write(buffer) }
      end
    end

    def add_external_files_to_zip(zipfile, file_set)
      return unless add_to_zip?(file_set)
      zipfile.get_output_stream(file_set.title.first) do |outfile|
        open_remote_file(file_set).each { |buffer| outfile.write(buffer) }
      end
    end

    def add_to_zip?(file_set)
      file_set.original_file.present? && (ability.can? :read, file_set.id) ? true : redirect_object?(file_set)
    end

    def redirect_object?(file_set)
      open_remote_file(file_set).status[0] == '200' && (ability.can? :read, file_set.id)
    end

    def open_remote_file(file_set)
      open(
        file_set.original_file.uri,
          http_basic_authentication: [ActiveFedora.fedora_config.credentials['user'], ActiveFedora.fedora_config.credentials['password']],
          allow_redirections: :all
      )
    end
end
