# frozen_string_literal: true
module Export
  class BatchConvertor < Sufia::Export::Converter
    def initialize(batch)
      @id = batch.id
      @status = batch.status
      @generic_file_ids = batch.generic_file_ids
    end
  end
end
