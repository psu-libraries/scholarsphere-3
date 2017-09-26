# frozen_string_literal: true

class CollectionForm < Sufia::Forms::CollectionForm
  attr_reader :current_ability, :request

  self.required_fields = [:title, :description, :keyword]

  # @param [Collection] model
  # @param [Ability] current_ability
  # @param [ActionDispatch::Request] request
  # Overrides CurationConcerns::CollectionEditForm to add current_ability and request to the form.
  def initialize(model, current_ability, request)
    @current_ability = current_ability
    @request = request
    super(model)
  end

  # @return [Array<WorkShowPresenter>]
  # This is so we can display the title and other pertinent information about the works
  # that will be added to a collection.
  def incorporated_work_presenters
    CurationConcerns::PresenterFactory.build_presenters(batch_document_ids,
                                                        WorkShowPresenter,
                                                        current_ability, request)
  end

  # return [Array<SolrDocument]
  def incorporated_member_docs
    incorporated_work_presenters.map(&:solr_document)
  end

  def primary_terms
    self.class.required_fields
  end

  def secondary_terms
    [
      :creator, :contributor, :rights, :publisher, :date_created, :subject, :language, :identifier,
      :based_near, :related_url, :resource_type
    ]
  end

  private

    def batch_document_ids
      return [] unless request
      request.filtered_parameters.fetch('batch_document_ids', [])
    end
end
