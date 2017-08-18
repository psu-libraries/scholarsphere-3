# frozen_string_literal: true

class NullRepresentativePresenter < FileSetPresenter
  # @param [Ability] current_ability
  # @param [ActionDispatch::Request] request the http request context
  def initialize(current_ability, request = nil)
    @solr_document = null_document
    @current_ability = current_ability
    @request = request
  end

  def display_download_link?
    false
  end

  private

    def null_document
      SolrDocument.new(thumbnail_path_ss: CurationConcerns::ThumbnailPathService.send(:default_image))
    end
end
