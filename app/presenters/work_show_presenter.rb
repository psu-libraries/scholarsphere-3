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

  # TODO: Remove once https://github.com/projecthydra/sufia/issues/2394 is resolved
  def member_presenters(ids = ordered_ids, presenter_class = composite_presenter_class)
    super.delete_if { |presenter| current_ability.cannot?(:read, presenter.solr_document) }
  end

  def uploading?
    QueuedFile.where(work_id: id).present?
  end
end
