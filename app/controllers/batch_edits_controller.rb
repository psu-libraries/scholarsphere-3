# frozen_string_literal: true

class BatchEditsController < ApplicationController
  include Hydra::BatchEditBehavior
  include FileSetHelper
  include Sufia::BatchEditsControllerBehavior

  def edit
    super
    work = BatchEditItem.new(batch: batch)
    work.depositor = current_user.user_key
    @form = form_class.new(work, current_user, batch)
  end

  def update
    batch.map { |id| update_document(ActiveFedora::Base.find(id)) }
    flash[:notice] = 'Batch update complete'
    after_update
  end

  # Remove (and its commit) when https://github.com/projecthydra/sufia/issues/2450 is closed
  # Updates terms, permissions, and visibility for a given object in a batch.
  # Note: Permissions and visibility are *always* copied down to any contained FileSet objects.
  #       There is no UI option presented to the user to prevent this, unlike the option that
  #       is present when changing permissions on a single work.
  def update_document(obj)
    visibility_changed = visibility_status(obj)
    obj.attributes = work_params
    obj.date_modified = Time.current.ctime
    obj.save
    VisibilityCopyJob.perform_later(obj) if visibility_changed
    InheritPermissionsJob.perform_later(obj) if work_params.fetch(:permissions_attributes, nil)
  end

  # The HTML form is being stupid and for some unknown reason, the array of batch ids being
  # sent to the controller has the anchor tag appended to them ex:
  #   { "batch_document_ids"=>["sx61dm33r", "4b29b601h#descriptions_display"] }
  # I don't know how this happening, so I'm cheating and just lopping them off here.
  def batch
    super.map { |id| id.split(/#/).first }
  end

  protected

    def form_class
      BatchEditForm
    end

    def work_params
      @work_params ||= build_work_params
    end

  private

    def build_work_params
      work_params = params[:batch_edit_item] || ActionController::Parameters.new
      form_class.model_attributes(work_params)
    end

    def visibility_status(object)
      selected_visibility = work_params.fetch(:visibility, nil)
      return false unless selected_visibility
      object.visibility != selected_visibility
    end
end
