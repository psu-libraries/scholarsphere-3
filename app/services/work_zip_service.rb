# frozen_string_literal: true

# A Service to take the contents of a work and convert it into a zip file.
#  It will take the original_file from each file set attached to the work
#  This service will only include files the ability can read
#  The zip file name will be returned from the call method
#
# @example
#   work = GenericWork.find(id) # work with file sets attached
#
#   service = WorkZipService.new(work, current_ability)
#
#   zip_file_name = service.call
#
class WorkZipService
  attr_reader :work, :ability, :zip_directory

  # Initialize the service
  #
  # @param [GenericWork]  work           work whose content will be zipped
  # @param [User|Ability] ability        User|Ability who will have access to the zip
  # @param [String]       zip_directory  Location to store zip file on disk
  def initialize(work, ability, zip_directory = 'tmp/')
    @work = work
    @ability = ability
    @zip_directory = zip_directory
  end

  # create the zip file
  #
  # @return [String] zip file name
  def call
    zipfile_name = File.join(zip_directory, "#{work.title.first.parameterize('_')}.zip")

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |_zipfile|
      work.file_sets.each do |file_set|
        add_file_set_to_zip(zip_file, file_set)
      end
    end
    zipfile_name
  end

  private

    def add_file_set_to_zip(zipfile, file_set)
      return unless file_set.original_file.present? && (ability.can? :read, file_set.id)

      zipfile.get_output_stream(file_set.title.first) do |outfile|
        file_set.original_file.stream.each { |buffer| outfile.write(buffer) }
      end
    end
end
