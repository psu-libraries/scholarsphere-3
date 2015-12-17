class ShareNotifyJob < ActiveFedoraIdBasedJob

  def run
    return if object.share_notified? || unshareable?
    Sufia.queue.push(notification_job)
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

    def notification_job
      if response.status == 201
        ShareNotifySuccessEventJob.new(generic_file.id, generic_file.depositor)
      else
        report_errors
      end
    end

    def report_errors
      Rails.logger.error(
        "Posting file #{object.id} to SHARE Notify failed with #{response.status}. Response was #{response.response}"
      )
      ShareNotifyFailureEventJob.new(generic_file.id, generic_file.depositor)
    end
end
