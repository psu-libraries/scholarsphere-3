# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor
      def create(attributes)
        stat = super(attributes)

        # TODO: When we move to RDF 2 we will need to remove this code.
        # Retains order in title and creator while we are on RDF 1.9.
        # The interim call to .save is needed, otherwise, resetting the order of titles
        # changes the order of the creators as well!
        curation_concern.creator = attributes[:creator]
        curation_concern.save
        curation_concern.title = attributes[:title]

        stat
      end
    end
  end
end
