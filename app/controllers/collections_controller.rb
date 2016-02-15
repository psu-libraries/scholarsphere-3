# frozen_string_literal: true
class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to collections.collection_path(new_id), status: :moved_permanently }
  end

  def presenter_class
    ::CollectionPresenter
  end

  def form_class
    ::CollectionEditForm
  end

  def filter_docs_with_read_access!
    super
    flash[:notice] = nil
  end
end
