# frozen_string_literal: true
module Export
  class GenericFileConverter < Sufia::Export::GenericFileConverter
    def initialize(generic_file)
      super

      # some files have a blank label which makes it harder to import them correcly
      #   use the mime type to add a label with the correct extension
      @label ||= "no_original_label#{Rack::Mime::MIME_TYPES.invert[generic_file.content.mime_type]}"
    end

    private

      def versions(gf)
        return [] unless gf.content.has_versions?
        Export::VersionGraphConverter.new(gf.content.versions).versions
      end
  end
end
