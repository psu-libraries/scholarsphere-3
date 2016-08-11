# frozen_string_literal: true
class CollectionsController < ApplicationController
  include CurationConcerns::CollectionsControllerBehavior
  include Sufia::CollectionsControllerBehavior

  self.presenter_class = ::CollectionPresenter

  prepend_before_action only: [:show, :edit] do
    handle_legacy_url_prefix { |new_id| redirect_to collection_path(new_id), status: :moved_permanently }
  end

  before_action :has_access?, except: :show

  # TODO: Move to CC?
  def filter_docs_with_read_access!
    super
    flash[:notice] = nil
  end
end
