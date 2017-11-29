# frozen_string_literal: true

# Used to return a set of WorkShowPresenters for recent_documents
module PrependedControllers::WithRecentPresenters
  protected

    def recent
      (_, documents) = search_results(q: '', sort: sort_field, rows: 4)
      @recent_documents = documents.map { |doc| WorkShowPresenter.new(doc, current_ability) }
    rescue Blacklight::Exceptions::ECONNREFUSED
      @recent_documents = []
    end
end
