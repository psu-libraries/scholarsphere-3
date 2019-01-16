# frozen_string_literal: true

class ImportVersionJob < ApplicationJob
  queue_as :files
  # @param [ActiveFedora::Base] the work class
  # @param [Array<UploadedFile>] an array of files to attach
  def perform(file_set, filename_on_disk)
    # characterize the current version
    CharacterizeJob.perform_now(file_set, file_set.original_file.id, filename_on_disk)
  ensure
    begin
      File.delete(filename_on_disk)
    rescue StandardError => e
      logger.warn("Error deleting #{filename_on_disk}: #{e.message}")
    end
  end
end
