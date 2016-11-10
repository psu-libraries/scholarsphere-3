# frozen_string_literal: true
class GenericFileContentService
  attr_reader :generic_file

  def initialize(generic_file)
    @generic_file = generic_file
  end

  def stream_content
    @stream_content ||= import_file
    @stream_content ||= temp_file
    @stream_content
  end

  def cleanup
    @temp_file.unlink unless @temp_file.nil?
    @temp_file = nil
  end

  private

    def import_file
      # no url no import file
      return nil if generic_file.import_url.blank?

      # url not file based no import file
      uri = URI(generic_file.import_url)
      return nil if uri.scheme != 'file'

      # file has been deleted no import file
      return nil unless File.exist?(uri.path)

      File.new(uri.path)
    end

    def temp_file
      # return the instance we already created
      return @file unless @file.nil?

      temp_file = Tempfile.new(temp_file_name)
      temp_file.binmode
      generic_file.content.stream.each do |chunk|
        temp_file.write(chunk)
      end
      temp_file.close
      @temp_file = temp_file
      @file = File.new(@temp_file)
    end

    def temp_file_name
      @temp_file_name ||= filename_for_temp_file.join("")
    end

    def filename_for_temp_file
      registered_mime_type = MIME::Types[generic_file.mime_type].first
      Rails.logger.warn "Unable to find a registered mime type for #{generic_file.mime_type.inspect} on #{generic_file.uri}" unless registered_mime_type
      extension = registered_mime_type ? ".#{registered_mime_type.extensions.first}" : ''
      version_id = 1 # TODO: fixme
      m = /\/([^\/]*)$/.match(generic_file.uri)
      ["#{m[1]}-#{version_id}", extension.to_s]
    end
end
