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

  def page_title
    "Work | #{title.first} | Work ID: #{solr_document.id} | ScholarSphere"
  end

  private

    # Override to add rows parameter
    # Remove this once we're on the latest CC
    # Also note: https://github.com/projecthydra-labs/hyrax/issues/352
    def file_set_ids
      @file_set_ids ||= begin
                          ActiveFedora::SolrService.query("{!field f=has_model_ssim}FileSet",
                                                          fl: ActiveFedora.id_field,
                                                          rows: 1000,
                                                          fq: "{!join from=ordered_targets_ssim to=id}id:\"#{id}/list_source\"")
                                                   .flat_map { |x| x.fetch(ActiveFedora.id_field, []) }
                        end
    end
end
