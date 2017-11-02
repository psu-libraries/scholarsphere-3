# frozen_string_literal: true

class WorkShowPresenter < Sufia::WorkShowPresenter
  include ActionView::Helpers::NumberHelper
  include Sufia::WithEvents

  delegate :bytes, :subtitle, to: :solr_document

  def creator_name
    solr_document.fetch('creator_name_tesim', [])
  end

  def size
    number_to_human_size(bytes)
  end

  def total_items
    solr_document.fetch('member_ids_ssim', []).length
  end

  def file_page(page)
    @file_page = page
  end

  # TODO: Remove once https://github.com/projecthydra/sufia/issues/2394 is resolved
  def member_presenters
    members = super.delete_if { |presenter| current_ability.cannot?(:read, presenter.solr_document) }
    Kaminari.paginate_array(members).page(@file_page).per(10)
  end

  def uploading?
    QueuedFile.where(work_id: id).present?
  end

  # Check for member presenters before rendering the representative in CurationConcerns::WorkShowPresenter
  # @ return [FileSetPresenter, NullRepresentativePresenter]
  def representative_presenter
    @representative_presenter ||= build_representative_presenter
  end

  # @return [Array<Hash>] maps a facet's entered value from the user to its cleaned value
  # @example { original_value => cleaned_value }
  def facet_mapping(field)
    config = FieldConfigurator.facet_fields[field]
    send(field).zip(FacetValueCleaningService.call(send(field), config)).to_h
  end

  def permission_badge_class
    PublicPermissionBadge
  end

  def event_class
    solr_document.hydra_model
  end

  def events(size = 100)
    super(size)
  end

  private

    # Override to add rows parameter
    # Remove this once we're on the latest CC
    # Also note: https://github.com/projecthydra-labs/hyrax/issues/352
    def file_set_ids
      @file_set_ids ||= begin
                          ActiveFedora::SolrService.query('{!field f=has_model_ssim}FileSet',
                                                          fl: ActiveFedora.id_field,
                                                          rows: 1000,
                                                          fq: "{!join from=ordered_targets_ssim to=id}id:\"#{id}/list_source\"")
                            .flat_map { |x| x.fetch(ActiveFedora.id_field, []) }
                        end
    end

    def build_representative_presenter
      selected_presenters = member_presenters.select { |presenter| presenter.id == representative_id }
      return NullRepresentativePresenter.new(current_ability, request) if selected_presenters.empty?
      selected_presenters.first
    end
end
