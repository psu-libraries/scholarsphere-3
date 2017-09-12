# frozen_string_literal: true

class Person < ActiveFedora::Base
  property :given_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :sur_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :psu_id, predicate: ::RDF::Vocab::FOAF.holdsAccount, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :orcid_id, predicate: ::RDF::URI('http://dbpedia.org/ontology/orcidId'), multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  # @todo this should be removed once we have implemented aliases
  property :display_name, predicate: ::RDF::Vocab::FOAF.name, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  # If ID exists, match on ID, else try to match name
  def self.find_or_create(attributes)
    attributes = attributes.with_indifferent_access
    attributes.delete(:id) if attributes[:id].blank?
    query_attrs = if attributes[:id].blank?
                    {
                      given_name_ssim: attributes[:given_name],
                      sur_name_ssim: attributes[:sur_name]
                    }
                  else
                    { id: attributes[:id] }
                  end
    person = Person.where(query_attrs).limit(1).first
    person ||= Person.create(attributes)
    person
  end
end
