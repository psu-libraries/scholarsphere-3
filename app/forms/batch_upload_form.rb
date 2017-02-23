# frozen_string_literal: true
class BatchUploadForm < Sufia::Forms::BatchUploadForm
  self.required_fields = CurationConcerns::GenericWorkForm.required_fields - [:resource_type]

  include WithCreator
  include WithCleanerAttributes

  def self.multiple?(term)
    CurationConcerns::GenericWorkForm.multiple?(term)
  end
end
