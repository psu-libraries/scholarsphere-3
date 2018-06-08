# frozen_string_literal: true

module PrependedSearchBuilders::WithMoreRows
  def initialize(*)
    super
    @rows = Collection.count + 1000
  end
end
