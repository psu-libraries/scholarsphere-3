# frozen_string_literal: true
class LanguageAuthorityImportJob < RDFAuthorityImportJob
  self.authority = "languages"
  self.default_options = { format: "rdfxml", predicate: RDF::URI("http://www.w3.org/2008/05/skos#prefLabel") }
end
