# frozen_string_literal: true

class MyController < ApplicationController
  include Sufia::MyControllerBehavior

  private

    # Overrides Sufia::MyControllerBehavior to build a presenter for the collection to which we
    # want to add selected works.
    def prepare_instance_variables_for_batch_control_display
      super
      @incorporate_collection_presenter = build_incorporate_collection_presenter
    end

    def build_incorporate_collection_presenter
      CurationConcerns::PresenterFactory.build_presenters([params.fetch(:add_files_to_collection, nil)],
                                                          CollectionPresenter,
                                                          current_ability, request).first
    end
end
