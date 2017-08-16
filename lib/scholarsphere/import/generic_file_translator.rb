# frozen_string_literal: true

module Import
  # Imports a Sufia 6.0-exported GenericFile into a Sufia PCDM GernericWork and FileSet
  class GenericFileTranslator < Sufia::Import::GenericFileTranslator
    # @param Hash settings (see super for more)
    #   @attr import_binary    - (default true) Import the binary content from sufia6 fedora instance
    #     If true, fedora_sufia6_user and fedora_sufia6_password must be set in config/application.rb
    def initialize(settings)
      super
      import_binary = settings.fetch(:import_binary, true)
      @file_set_builder = Import::FileSetBuilder.new(import_binary)
      @work_builder = Import::WorkBuilder.new
    end
  end
end
