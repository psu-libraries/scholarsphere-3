# frozen_string_literal: true
# Queries the SHARE search api for an existing record. This assumes the class into which this
# module is included responds to #url and that in turn is mapped to the docID of the Share
# document that was originally uploaded via the SHARE push API.
module ShareNotify::Metadata
  extend ActiveSupport::Concern

  def share_notified?
    return if response.status != 200
    return false if response.count < 1
    response.docs.first.doc_id == url
  end

  def call
    api.search("shareProperties.docID:\"#{url}\"")
  end

  private

    def response
      @response ||= ShareNotify::SearchResponse.new(call)
    end

    def api
      @api ||= ShareNotify::NotifyAPI.new
    end
end
