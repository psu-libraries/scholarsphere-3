# frozen_string_literal: true
class Collection < Sufia::Collection
  # Override if you are storing your file size in a different way
  def stored_integer_descriptor
    GenericFileIndexingService::STORED_SYMBOL
  end
end
