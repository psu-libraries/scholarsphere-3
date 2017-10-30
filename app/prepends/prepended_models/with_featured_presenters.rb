# frozen_string_literal: true

# Used to return a set of WorkShowPresenters for featured works
module PrependedModels::WithFeaturedPresenters
  private

    def work_presenters
      ability = nil
      CurationConcerns::PresenterFactory.build_presenters(ids,
                                                          WorkShowPresenter,
                                                          ability)
    end
end
