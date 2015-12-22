# Encapsulates the response from the SHARE Search api
module ShareNotify
  class SearchResponse
    attr_reader :status, :response

    # @param [HTTParty::Response] response returned from ShareNotify::API
    def initialize(response)
      raise ArgumentError, "API response is nil" if response.nil?
      @status = response.code
      @response = response.parsed_response
    end

    def count
      response.fetch("count", 0)
    end

    def docs
      @docs ||= response.fetch("results", []).map { |d| Document.new(d) }
    end

    class Document
      attr_reader :doc

      def initialize(doc)
        @doc = doc
      end

      def contributors
        doc.fetch("contributors", [])
      end

      def title
        doc.fetch("title", nil)
      end

      def properties
        doc.fetch("shareProperties", nil)
      end

      def doc_id
        return if properties.nil?
        properties.fetch("docID", nil)
      end

      def source
        return if properties.nil?
        properties.fetch("source", nil)
      end

      def updated
        time_string = doc.fetch("providerUpdatedDateTime", nil)
        return if time_string.nil?
        Time.parse(time_string)
      end

      def uris
        doc.fetch("uris", nil)
      end

      def canonical_uri
        return if uris.nil?
        uris.fetch("canonicalUri", nil)
      end

      def provider_uris
        return if uris.nil?
        uris.fetch("providerUris", [])
      end
    end
  end
end
