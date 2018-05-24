# frozen_string_literal: true

# ActiveFedora::WithMetadata::MetadataNode redefines `.property` after the
# definition of `:mime_type`. The redefined method references a class
# variable `.parent_class` that is set on subclasses, but is `nil` on the
# base class. We need to redefine mime_type on the base class which
# results in an error delegating to `nil`.

# To get around this we capture the redefined method then set
# property back to the original method. We call this original
# version once to set mime_type then put the redefined method back
# in place.

# Call the class Hydra::PCDM::File without any method invocation because it
# includes WithMetadata and we need to resolve it before the method redefinition happens
Hydra::PCDM::File
old_method = ActiveFedora::WithMetadata::MetadataNode.method(:property)
ActiveFedora::WithMetadata::MetadataNode.define_singleton_method(:property) { |name, **opts| super(name, **opts) }
ActiveFedora::WithMetadata::MetadataNode.property :mime_type, predicate: RDF::URI.intern('http://scholarsphere.psu.edu/ns#mimeType')

# `old_method` is an instance of `Method`, but we need a block.
# `.curry` gives us a proc , which can pass as a block with the
# `&` syntax.
ActiveFedora::WithMetadata::MetadataNode.define_singleton_method(:property, &old_method.curry)
