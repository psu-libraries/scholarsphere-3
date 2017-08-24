# frozen_string_literal: true

class Person < ActiveFedora::Base
  property :first_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false
  property :last_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false
end
