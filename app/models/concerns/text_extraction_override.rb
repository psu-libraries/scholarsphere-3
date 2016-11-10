# frozen_string_literal: true
module TextExtractionOverride
  private

    def stream_service
      @stream_service ||= GenericFileContentService.new(self)
    end

    def extract_content
      return if content.size > 5_368_709_120 # large than 5 GB do not extract text

      extract_url = '/update/extract?extractOnly=true&wt=json&extractFormat=text'
      uri = URI(connection_url + extract_url)
      conn = Faraday.new(url: "#{uri.scheme}://#{uri.host}:#{uri.port}")
      resp = conn.post do |req|
        req.url "#{uri.path}?#{uri.query}"
        req.headers['Content-Type'] = "#{mime_type};charset=utf-8"
        req.headers['Content-Length'] = content.size.to_s
        req.body = Faraday::UploadIO.new(stream_service.stream_content.path, mime_type)
      end
      raise "URL '#{uri}' returned code #{resp.status}" unless resp.success?
      content.content.rewind if content.content.respond_to?(:rewind)
      extracted_text = JSON.parse(resp.body)[''].rstrip
      full_text.content = extracted_text if extracted_text.present?
    rescue => e
      logger.error("Error extracting content from #{id}: #{e.inspect}")
    ensure
      stream_service.cleanup
    end
end
