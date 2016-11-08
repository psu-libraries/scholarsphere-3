# frozen_string_literal: true
class RegisterQueuedFileJob < ActiveJob::Base
  def perform(curation_concern)
    return if QueuedFile.where(work_id: curation_concern.id).present?
    QueuedFile.create(work_id: curation_concern.id)
  end
end
