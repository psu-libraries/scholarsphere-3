# frozen_string_literal: true
# Loads vocabulary terms for languages and subjects into database tables that are
# used by Questioning Authority to return valid terms for user input.
class RDFAuthorityImporter
  class << self
    # @param [String] file path to the rdfxml file
    # @option opts [String] :format defaults to "rdfxml"
    # @option opts [RDF::URI] :predicate defaults to "http://www.w3.org/2008/05/skos#prefLabel"
    def import_languages(file, opts = {})
      Qa::LocalAuthority.find_or_create_by(name: "languages")
      Qa::Services::RDFAuthorityParser.import_rdf("languages", [file], default_language_options.merge!(opts))
    end

    # @param [String] file path to the rdfxml file
    # @option opts [String] :format defaults to "rdfxml"
    # @option opts [RDF::URI] :predicate defaults to RDF::Vocab::SKOS.prefLabel
    def import_subjects(file, opts = {})
      Qa::LocalAuthority.find_or_create_by(name: "subjects")
      Qa::Services::RDFAuthorityParser.import_rdf("subjects", [file], { format: 'rdfxml' }.merge!(opts))
    end

    def default_language_options
      { format: "rdfxml", predicate: RDF::URI("http://www.w3.org/2008/05/skos#prefLabel") }
    end
  end
end
