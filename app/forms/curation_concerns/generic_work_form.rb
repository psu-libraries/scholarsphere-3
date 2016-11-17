# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions
    self.terms += [:resource_type]
    self.required_fields += [:description, :resource_type]

    def self.multiple?(term)
      return false if term == :rights
      super
    end

    def initialize_field(key)
      if key == :creator
        self[key] = creator
      else
        super
      end
    end

    private

      def creator
        @creator ||= [Namae::Name.parse(current_ability.current_user.name).sort_order]
        @creator
      end
  end
end
