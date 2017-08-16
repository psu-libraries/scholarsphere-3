# frozen_string_literal: true

# Builder for generating a File set incluing permissions and versions
#
module Import
  class FileSetBuilder < Sufia::Import::FileSetBuilder
    # @param import_binary boolean indicating whether to import the binary from sufia6 fedora instance
    #     If true, fedora_sufia6_user and fedora_sufia6_password must be set in config/application.rb
    def initialize(import_binary)
      super
      @version_builder = Import::VersionBuilder.new
    end
  end
end
