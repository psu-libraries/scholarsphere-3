# frozen_string_literal: true
class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include Sufia::WorksControllerBehavior

  self.curation_concern_type = GenericWork

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to sufia.generic_file_path(new_id), status: :moved_permanently }
  end

  around_action :notify_users_of_permission_changes, only: [:update]
  before_action :has_access?, except: [:show, :stats]
  before_action :delete_from_share, only: [:destroy]

  def notify_users_of_permission_changes
    return if @curation_concern.nil?
    previous_permissions = @curation_concern.permissions.map(&:to_hash)
    yield
    current_permissions = @curation_concern.permissions.map(&:to_hash)
    PermissionsChangeService.new(
      PermissionsChangeSet.new(previous_permissions, current_permissions),
      @curation_concern
    ).call
  end

  def delete_from_share
    job = ShareNotifyDeleteJob.new(@curation_concern.id)
    job.document
    Sufia.queue.push(job)
  end
end
