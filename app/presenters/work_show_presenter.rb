# frozen_string_literal: true
class WorkShowPresenter < Sufia::WorkShowPresenter
  include ActionView::Helpers::NumberHelper

  delegate :bytes, to: :solr_document

  def size
    number_to_human_size(bytes)
  end

  def total_items
    solr_document.fetch('member_ids_ssim', []).length
  end
end
