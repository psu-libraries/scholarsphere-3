# frozen_string_literal: true

class BatchUploadForm < Sufia::Forms::BatchUploadForm
  self.required_fields = CurationConcerns::GenericWorkForm.required_fields - [:resource_type]

  include WithCreator
  include WithCleanerAttributes
  include WithOpenAccess

  def self.multiple?(term)
    CurationConcerns::GenericWorkForm.multiple?(term)
  end

  def target_selector
    "#new_#{model.model_name.param_key}"
  end

  def model_class_name
    'batch_upload_item'
  end

  # I am setting this to the default since we are not using admin sets
  #  If this is not present you get an error saving
  def admin_set_id
    AdminSet::DEFAULT_ID
  end

  def show_doi_form?
    false
  end
end
