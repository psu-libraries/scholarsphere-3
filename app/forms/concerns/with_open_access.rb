# frozen_string_literal: true

# When included in a form class, this defaults any new record to public visibility
module WithOpenAccess
  extend ActiveSupport::Concern

  included do
    def visibility
      return Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC if model.new_record?
      model.visibility
    end
  end
end
