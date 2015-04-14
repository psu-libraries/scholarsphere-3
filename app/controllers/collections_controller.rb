class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  prepend_before_filter only: [:show, :edit] do  
    handle_legacy_url_prefix do |new_id|
      redirect_to collections.collection_path(new_id), status: :moved_permanently
    end
  end 

  def presenter_class
    ::CollectionPresenter
  end

  def form_class
    ::CollectionEditForm
  end
end
