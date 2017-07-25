# frozen_string_literal: true
class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include Sufia::WorksControllerBehavior

  self.curation_concern_type = GenericWork
  self.show_presenter = ::WorkShowPresenter

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to sufia.generic_file_path(new_id), status: :moved_permanently }
  end

  around_action :notify_users_of_permission_changes, only: [:update]
  before_action :has_access?, except: [:show, :stats]
  before_action :delete_from_share, only: [:destroy]
  before_action :redirect_when_uploading, only: [:edit, :update, :destroy]

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
    ShareNotifyDeleteJob.perform_later(@curation_concern)
  end

  def redirect_when_uploading
    return unless QueuedFile.where(work_id: params[:id]).present?
    flash[:notice] = 'Edits or deletes not allowed while files are being uploaded to a work'
    redirect_to polymorphic_path([main_app, curation_concern])
  end

  protected

    # TODO: Ticketed new feature in Sufia to make this configurable or change
    # See https://github.com/projecthydra/curation_concerns/issues/1052
    # closes https://github.com/projecthydra/sufia/issues/2447
    def after_destroy_response(title)
      flash[:notice] = "Deleted #{title}"
      respond_to do |wants|
        wants.html { redirect_to Sufia::Engine.routes.url_helpers.dashboard_works_path }
        wants.json { render_json_response(response_type: :deleted, message: "Deleted #{curation_concern.id}") }
      end
    end

    # Overrides Sufia to reload curation_concern so that removed permissions will be checked.
    def permissions_changed?
      curation_concern.reload
      @saved_permissions != curation_concern.permissions.map(&:to_hash)
    end
end
