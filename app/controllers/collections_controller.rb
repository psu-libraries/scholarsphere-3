class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  def presenter
    ::CollectionPresenter.new(@collection)
  end

  def initialize_fields_for_edit
    @form = ::CollectionEditForm.new(@collection)
  end
end
