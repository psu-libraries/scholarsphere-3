class CollectionPresenter < Sufia::CollectionPresenter
  self.terms = [:title, :description, :total_items, :size, :creator, :date_modified, :date_uploaded]

  def size
    number_to_human_size(@bytes)
  end

  def size= bytes
    @bytes = bytes
  end

end
