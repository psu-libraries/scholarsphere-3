# frozen_string_literal: true

module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior
    include Sufia::FileSetsControllerBehavior

    self.show_presenter = ::FileSetPresenter

    # overriding curation concerns for the rails 5 parameter permission
    def update
      success = if wants_to_revert?
                  actor.revert_content(params[:revision])
                elsif params.key?(:file_set)
                  if params[:file_set].key?(:files)
                    actor.update_content(params.require(:file_set)[:files].first)
                  else
                    update_metadata
                  end
                end
      if success
        after_update_response
      else
        respond_to do |wants|
          wants.html do
            initialize_edit_form
            flash[:error] = 'There was a problem processing your request.'
            render 'edit', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    rescue RSolr::Error::Http => error
      flash[:error] = error.message
      logger.error "FileSetsController::update rescued #{error.class}\n\t#{error.message}\n #{error.backtrace.join("\n")}\n\n"
      render action: 'edit'
    end
  end
end
