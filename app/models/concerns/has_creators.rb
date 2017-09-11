# frozen_string_literal: true

module HasCreators
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :creators, class_name: 'Person', predicate: ::RDF::Vocab::DC11.creator
    alias_method :creator, :creators

    def creators=(values)
      values = values.values if values.is_a? Hash
      person_records = values.map do |v|
        if v.is_a? Person
          v
        else
          Person.find_or_create(v)
        end
      end
      super(person_records)
    end
  end
end
