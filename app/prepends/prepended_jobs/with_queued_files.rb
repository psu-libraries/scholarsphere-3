# frozen_string_literal: true
# This is a prepend intended to be used with AttachFilesToWorkJob.
# Removes each queued file after it is added to the work.
module PrependedJobs::WithQueuedFiles
  def perform(work, uploaded_files)
    super
    QueuedFile.where(work_id: work.id).destroy_all
  end
end
