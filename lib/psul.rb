# frozen_string_literal: true

class PSUL < RDF::StrictVocabulary('http://libraries.psu.edu/ns/')
  property :orderedCreators,
    comment: %(A delimited string of creator ids in a specific order.),
    label: 'Ordered Creators'
end
