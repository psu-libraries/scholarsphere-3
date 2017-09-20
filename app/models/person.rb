# frozen_string_literal: true

class Person < ActiveFedora::Base
  has_many :aliases

  property :given_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :sur_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end
end
