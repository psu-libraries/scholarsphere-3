# frozen_string_literal: true

module WithLocalWorkFormService
  extend ActiveSupport::Concern

  included do
    self.work_form_service = BatchUploadFormService
  end
end
