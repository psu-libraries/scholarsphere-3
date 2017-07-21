# frozen_string_literal: true
class CollectionsController < ApplicationController
  include CurationConcerns::CollectionsControllerBehavior
  include Sufia::CollectionsControllerBehavior

  self.presenter_class = ::CollectionPresenter
  self.form_class = ::CollectionForm

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to collection_path(new_id), status: :moved_permanently }
  end

  before_action :has_access?, except: :show

  # TODO: Move to CC?
  def filter_docs_with_read_access!
    super
    flash[:notice] = nil
  end

  # Overrides CurationConcerns::CollectionsControllerBehavior
  # Redirects either to:
  #   1) collection view page of the newly created collection
  #   2) batch create page with newly created collection added to relationships so that
  #      the user may add new works to the collection
  #   3) dashboard work page with newly created collection selected so that user may add
  #      existing works to the collection.
  def after_create
    form
    respond_to do |format|
      ActiveFedora::SolrService.instance.conn.commit
      format.html { redirect_to after_create_path, notice: "Collection was successfully created." }
      format.json { render json: @collection, status: :created, location: @collection }
    end
  end

  # Overrides CurationConcerns::CollectionsControllerBehavior
  # Redirects to the user's collections dashboard page
  def after_destroy(id)
    respond_to do |format|
      format.html { redirect_to sufia.dashboard_collections_path, notice: "Collection was successfully deleted." }
      format.json { render json: { id: id }, status: :destroyed, location: @collection }
    end
  end

  # Overrides CurationConcerns::CollectionsControllerBehavior
  # Redirects to the user's collections dashboard page
  def after_destroy_error(id)
    respond_to do |format|
      format.html { redirect_to sufia.dashboard_collections_path, notice: "Collection could not be deleted." }
      format.json { render json: { id: id }, status: :destroy_error, location: @collection }
    end
  end

  protected

    # Override CurationConcerns::CollectionsControllerBehavior to build a form with ability and request
    def form
      @form ||= form_class.new(@collection, current_ability, request)
    end

  private

    # TODO: Logic is dependent on what's in the view. This could be moved into the form
    # for better decoupling.
    def after_create_path
      if params.fetch(:create_collection_and_upload_works, nil)
        sufia.new_batch_upload_path(collection_ids: [@collection])
      elsif params.fetch(:create_collection_and_add_existing_works, nil)
        sufia.dashboard_works_path(add_files_to_collection: @collection)
      else
        collection_path(@collection)
      end
    end
end
