# frozen_string_literal: true

class BatchUploadFormService < CurationConcerns::WorkFormService
  # Gives the class of the form.
  def self.form_class(_curation_concern = nil)
    BatchUploadForm
  end
end
