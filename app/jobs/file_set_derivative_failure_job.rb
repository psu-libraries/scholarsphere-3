# frozen_string_literal: true

class FileSetDerivativeFailureJob < FileSetAttachedEventJob
  # Log the event to the fileset's and its container's streams
  def log_event(repo_object)
    repo_object.log_event(event)
    curation_concern.log_event(event) if curation_concern.present?
  end

  def action
    "The derivative for #{link_to repo_object.title.first, polymorphic_path(repo_object)} was not successfully created"
  end
end
