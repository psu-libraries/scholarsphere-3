# frozen_string_literal: true
# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  module Actors
    class GenericWorkActor < CurationConcerns::Actors::BaseActor
      def create(attributes)
        stat = super(attributes)

        # TODO: when we move to RDF 2 we will need to remove this code
        # This code is a patch to keep order only while we are on RDF 1.9
        # assign again to keep creator order
        curation_concern.creator = attributes[:creator]
        stat
      end
    end
  end
end
