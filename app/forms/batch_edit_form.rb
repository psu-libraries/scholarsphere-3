# frozen_string_literal: true

class BatchEditForm < Sufia::Forms::BatchEditForm
  include WithCreator
  include WithCleanerAttributes

  def model_class_name
    'batch_edit_item'
  end

  def initialize_combined_fields
    assign_combined_attributes_to_model
    @names = combinator.names
    model.creators = combinator.creators
    model.admin_set_id = AdminSet::DEFAULT_ID
    model.permissions_attributes = combinator.permissions
  end

  # Copies the single value code from the generic work form to be used exclusively for rights in batch edit
  # https://github.com/samvera/sufia/wiki/Customizing-Metadata#making-a-default-property-non-repeatable
  def self.multiple?(field)
    if [:rights].include? field.to_sym
      false
    else
      super
    end
  end

  def self.model_attributes(_)
    attrs = super
    attrs[:rights] = Array(attrs[:rights]) if attrs[:rights]
    attrs
  end

  private

    # Assigns each of the combined attributes to {model}, creating an empty array for null attributes.
    def assign_combined_attributes_to_model
      combined_attributes.keys.each do |key|
        model[key] = combined_attributes[key].empty? ? [''] : combined_attributes[key]
      end
    end

    def combinator
      @combinator ||= Combinator.new(batch_document_ids, model_class)
    end

    def combined_attributes
      @combined_attributes ||= combinator.attributes(terms - [:creator])
    end

    class Combinator
      attr_reader :works

      # @param [Array<String>] ids of works to edit
      # @param [ActiveFedora::Base] model_class of the works
      def initialize(ids, model_class)
        @works = ids.map { |id| model_class.find(id) }
      end

      # @param [Array<Symbol>] keys for attributes that we want to combine
      # @return [Hash] with keys of attributes and their combined values from the works
      # object[key] returns a ActiveTriples::Relation which must be cast to an array in order to flatten it
      def attributes(keys)
        results = {}
        keys.each do |key|
          results[key] = works.map { |work| work[key].to_a }.flatten.uniq
        end
        results
      end

      def creators
        works.map(&:creators).flatten
      end

      def names
        works.map(&:to_s)
      end

      def permissions
        combined_permissions = works.map(&:permissions).flatten
        combined_permissions.map(&:to_hash).uniq
      end
    end
end
