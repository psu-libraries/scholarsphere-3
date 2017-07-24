# frozen_string_literal: true
# Base class for jobs that import authority records into database tables
class RDFAuthorityImportJob < ActiveJob::Base
  class_attribute :authority, :default_options
  self.default_options = {}
  queue_as :authority_import

  def perform(file, opts = {})
    raise(NotImplementedError, 'No authority defined') if authority.nil?
    Qa::LocalAuthority.find_or_create_by(name: authority)
    Qa::Services::RDFAuthorityParser.import_rdf(authority, [file], default_options.merge!(opts))
  end
end
