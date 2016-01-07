class ShareNotifyJob < ActiveFedoraIdBasedJob

  def run
    return if object.share_notified? || unshareable?
    share.post(GenericFileToShareJSONService.new(object).json)
    report_errors unless share.response.code == 201
    update_file
    Sufia.queue.push(ShareNotifyEventJob.new(generic_file.id, generic_file.depositor))
  end

  def unshareable?
    ShareNotifyFilteredList.new(
      ResourceFilteredList.new(
        PublicFilteredList.new([object]).filter
      ).filter
    ).filter.empty?
  end

  private

    def share
      @share ||= ShareNotify::API.new
    end

    def report_errors
      Rails.logger.warn(
        "Posting #{share.response.request.raw_body} failed to send to SHARE Notify. Response was #{share.response}"
      )
    end

    def update_file
      object.share_notify_id = share.response.to_hash["id"]
      object.save
    end

end
