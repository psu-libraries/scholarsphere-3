# frozen_string_literal: true

CurationConcerns.config.callback.set(:after_create_concern) do |curation_concern, user|
  RegisterQueuedFileJob.perform_now(curation_concern)
  ContentDepositEventJob.perform_later(curation_concern, user)
  ShareNotifyJob.perform_later(curation_concern)
end

# Update the file set's title and label with the file name of the reverted content
CurationConcerns.config.callback.set(:after_revert_content) do |file_set, _user, _revision_id|
  file_set.reload
  new_title = file_set.original_file.metadata_node.file_name
  file_set.label = new_title.first
  file_set.title = new_title
  file_set.save
end
