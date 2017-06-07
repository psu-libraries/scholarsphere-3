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
        curation_concern.creator = attributes[:creator]
        curation_concern.creator = attributes[:title]

        stat
      end
    end
  end
end
