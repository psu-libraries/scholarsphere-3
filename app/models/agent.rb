# frozen_string_literal: true

class Agent < ActiveFedora::Base
  has_many :aliases

  def valkyrie_resource
    Valkyrie::Agent
  end

  property :given_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :sur_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :psu_id, predicate: ::RDF::Vocab::FOAF.holdsAccount, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :email, predicate: ::RDF::Vocab::SCHEMA.email, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  property :orcid_id, predicate: ::RDF::URI('http://dbpedia.org/ontology/orcidId'), multiple: false do |index|
    index.as :stored_searchable, :symbol
  end

  def display_name
    "#{given_name} #{sur_name}"
  end

  def attributes_including_linked_ids
    attributes.merge(alias_ids: alias_ids).with_indifferent_access
  end
end
