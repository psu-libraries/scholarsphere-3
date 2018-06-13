# frozen_string_literal: true

# This is a prepend intended to be used with AttachFilesToWorkJob.
# Removes each queued file after it is added to the work.
module PrependedJobs::WithQueuedFiles
  # @param [ActiveFedora::Base] the work class
  # @param [Array<UploadedFile>] an array of files to attach
  # @param [HashWithIndifferentAccess] hash of visibility parameters
  def perform(work, uploaded_files, visibility_attributes)
    uploaded_files.each do |uploaded_file|
      file_set = FileSet.new
      user = User.find_by(login: work.depositor)
      actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
      actor.create_metadata(work, visibility_attributes) do |file|
        file.permissions_attributes = work.permissions.map(&:to_hash)
      end

      attach_content(actor, uploaded_file.file)
      uploaded_file.update(file_set_uri: file_set.uri)
    end
    QueuedFile.where(work_id: work.id).destroy_all
  end
end
