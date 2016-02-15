# frozen_string_literal: true
class CollectionPresenter < Sufia::CollectionPresenter
  self.terms = [:title, :description, :total_items, :size, :creator, :date_modified, :date_uploaded]
end
