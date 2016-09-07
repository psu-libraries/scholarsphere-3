# frozen_string_literal: true
CurationConcerns.config.callback.set(:after_create_concern) do |curation_concern, user|
  ContentDepositEventJob.perform_later(curation_concern, user)
  ShareNotifyJob.perform_later(curation_concern)
end
