# frozen_string_literal: true

# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
    self.terms += [:resource_type, :subtitle]
    self.required_fields += [:description, :resource_type]

    include HydraEditor::Form::Permissions
    include WithCreator
    include WithCleanerAttributes
    include WithOpenAccess

    def self.multiple?(field)
      if [:title, :rights].include? field.to_sym
        false
      else
        super
      end
    end

    def self.model_attributes(_)
      attrs = super
      attrs[:title] = Array(attrs[:title]) if attrs[:title]
      attrs[:rights] = Array(attrs[:rights]) if attrs[:rights]
      attrs
    end

    def title
      super.first || ''
    end

    def rights
      super.first || ''
    end

    # Fields that are automatically drawn on the page above the fold
    def primary_terms
      [:title, :subtitle, :creator, :keyword, :rights, :description, :resource_type]
    end

    def target_selector
      if persisted?
        "#edit_#{model.model_name.param_key}_#{model.id}"
      else
        "#new_#{model.model_name.param_key}"
      end
    end

    def select_files
      available_files = file_presenters.select do |file|
        model.visibility == file.solr_document.visibility
      end
      Hash[available_files.map { |file| [file.to_s, file.id] }]
    end
  end
end
