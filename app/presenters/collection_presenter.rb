class CollectionPresenter < Sufia::CollectionPresenter
  include Hydra::Presenter
  include ActionView::Helpers::NumberHelper

  self.terms = [:title, :description, :creator, :date_modified, :date_uploaded]
end
