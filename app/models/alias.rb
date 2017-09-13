# frozen_string_literal: true

class Alias < ActiveFedora::Base
  include Hydra::PCDM::ObjectBehavior

  belongs_to :person, class_name: 'Person', predicate: ::RDF::Vocab::FOAF.name

  property :display_name, predicate: ::RDF::Vocab::FOAF.nick, multiple: false do |index|
    index.as :stored_searchable, :symbol
  end
end
