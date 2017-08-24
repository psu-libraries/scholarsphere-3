# frozen_string_literal: true

class Person < ActiveFedora::Base
  property :first_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :last_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  # If ID exists, match on ID, else try to match name
  def self.find_or_create(attributes)
    attributes = attributes.with_indifferent_access
    attributes.delete(:id) if attributes[:id].blank?
    query_attrs = if attributes[:id].blank?
                    {
                      first_name_ssim: attributes[:first_name],
                      last_name_ssim: attributes[:last_name]
                    }
                  else
                    { id: attributes[:id] }
                  end
    person = Person.where(query_attrs).limit(1).first
    person ||= Person.create(attributes)
    person
  end
end
