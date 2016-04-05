# frozen_string_literal: true
class GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  # Adds Sufia behaviors to the controller.
  include Sufia::WorksControllerBehavior

  self.curation_concern_type = GenericWork

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to sufia.generic_file_path(new_id), status: :moved_permanently }
  end

  # TODO: This is a temporary override of sufia to fix #101
  #      This can be removed once sufia has a solution and we upgrade or
  #      batches are no longer used when sufia migrates to PCDM
  # routed to /files/new
  def new
    @batch_id = Batch.create.id
  end

  around_action :notify_users_of_permission_changes, only: [:update]
  skip_before_action :has_access?, only: [:stats]
  before_action :delete_from_share, only: [:destroy]

  def notify_users_of_permission_changes
    return if @generic_file.nil?
    previous_permissions = @generic_file.permissions.map(&:to_hash)
    yield
    current_permissions = @generic_file.permissions.map(&:to_hash)
    PermissionsChangeService.new(
      PermissionsChangeSet.new(previous_permissions, current_permissions),
      @generic_file
    ).call
  end

  def delete_from_share
    job = ShareNotifyDeleteJob.new(@generic_file.id)
    job.document
    Sufia.queue.push(job)
  end
end
