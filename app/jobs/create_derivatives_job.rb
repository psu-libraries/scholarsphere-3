# frozen_string_literal: true

# Replaces CurationConcerns job to rescue from derivative creation failures and notify the user.
class CreateDerivativesJob < ApplicationJob
  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the CurationConcerns.config.working_path
  def perform(file_set, file_id, filepath = nil)
    return if file_set.video? && !CurationConcerns.config.enable_ffmpeg

    filename = CurationConcerns::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)

    file_set.create_derivatives(filename)

    # Reload from Fedora and reindex for thumbnail and extracted text
    file_set.reload
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  rescue StandardError => e
    notify_user(file_set)
    raise(e)
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent

    file_set.parent.thumbnail_id == file_set.id || file_set.label =~ /^readme/i
  end

  private

    def notify_user(file_set)
      user = User.find_by(login: file_set.depositor)
      FileSetDerivativeFailureJob.perform_later(file_set, user)
    end
end
