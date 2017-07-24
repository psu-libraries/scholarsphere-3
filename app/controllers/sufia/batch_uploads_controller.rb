# frozen_string_literal: true
class Sufia::BatchUploadsController < ApplicationController
  include Sufia::BatchUploadsControllerBehavior

  def self.form_class
    BatchUploadForm
  end

  protected

    # Override the default behavior from curation_concerns in order to add uploaded_files to the parameters received by the actor.
    def attributes_for_actor
      attributes = super
      # If they selected a BrowseEverything file, but then clicked the
      # remove button, it will still show up in `selected_files`, but
      # it will no longer be in uploaded_files. By checking the
      # intersection, we get the files they added via BrowseEverything
      # that they have not removed from the upload widget.
      uploaded_files = params.fetch(:uploaded_files, [])
      selected_files = params.fetch(:selected_files, {}).values
      browse_everything_urls = uploaded_files &
                               selected_files.map { |f| f[:url] }

      # we need the hash of files with url and file_name
      browse_everything_files = selected_files
                                .select { |v| uploaded_files.include?(v[:url]) }

      attributes[:remote_files] = browse_everything_files
      # Strip out any BrowseEverthing files from the regular uploads.
      attributes[:uploaded_files] = uploaded_files -
                                    browse_everything_urls
      attributes
    end

    def create_update_job
      log = Sufia::BatchCreateOperation.create!(user: current_user,
                                                operation_type: 'Batch Create')
      # ActionController::Parameters are not serializable, so cast to a hash
      BatchCreateJob.perform_later(current_user,
                                   params[:title].permit!.to_h,
                                   params[:resource_type].permit!.to_h,
                                   attributes_for_actor.to_h,
                                   log)
    end

    def uploading_on_behalf_of?
      params.fetch(hash_key_for_curation_concern).fetch(:on_behalf_of, nil).present?
    end

    # Overrides Sufia to redirect to a collection's show page if needed
    def redirect_after_update
      if collection?
        redirect_to collection_path(attributes_for_actor.fetch(:collection_ids).first)
      elsif uploading_on_behalf_of?
        redirect_to sufia.dashboard_shares_path
      else
        redirect_to sufia.dashboard_works_path
      end
    end

  private

    def collection?
      attributes_for_actor.fetch(:collection_ids, []).present?
    end
end
