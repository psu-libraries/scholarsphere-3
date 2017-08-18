# frozen_string_literal: true

class SubjectAuthorityImportJob < RDFAuthorityImportJob
  self.authority = 'subjects'
  self.default_options = { format: 'rdfxml' }
end
