class CollectionPresenter < Sufia::CollectionPresenter

  self.terms = [:title, :description, :total_items, :size, :creator, :date_created, :date_modified]

  def size
    super
  end

  def total_items
    super
  end
end
