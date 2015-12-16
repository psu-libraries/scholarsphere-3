class ShareNotifyJob < ActiveFedoraIdBasedJob

  def run
    return if object.share_notified? || unshareable?
    report_errors unless response.status == 201
    Sufia.queue.push(ShareNotifyEventJob.new(generic_file.id, generic_file.depositor))
  end

  def unshareable?
    ResourceFilteredList.new(
      PublicFilteredList.new([object]).filter
    ).filter.empty?
  end

  private

    def share
      @share ||= ShareNotify::API.new
    end

    def response
      @response ||= ShareNotify::SearchResponse.new(
                      share.post(GenericFileToShareJSONService.new(object).json)
                    )
    end

    def report_errors
      Rails.logger.warn(
        "Posting #{share.response.request.raw_body} failed to send to SHARE Notify. Response was #{share.response}"
      )
    end
end
