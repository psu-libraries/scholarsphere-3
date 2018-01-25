# frozen_string_literal: true

class BatchEditsController < ApplicationController
  include Hydra::BatchEditBehavior
  include FileSetHelper
  include Sufia::BatchEditsControllerBehavior

  # @todo See https://github.com/psu-stewardship/scholarsphere/issues/1038
  def edit
    super
    work = BatchEditItem.new(batch: batch)
    work.depositor = current_user.user_key
    @form = form_class.new(work, current_ability, batch)
  end

  def update
    batch.map { |id| BatchItemUpdateService.new(id, work_params, current_user).update }
    flash[:notice] = 'Batch update complete'
    after_update
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
      work_params = params[:batch_edit_item] || ActionController::Parameters.new
      form_class.model_attributes(work_params)
    end
end
