class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  def presenter_class
    ::CollectionPresenter
  end

  def form_class
    ::CollectionEditForm
  end
end
