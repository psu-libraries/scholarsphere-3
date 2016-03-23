# frozen_string_literal: true
class ShareNotifyDeleteJob < ShareNotifyJob
  def run
    return unless object.share_notified?
    Sufia.queue.push(notification_job)
  end

  private

    def response
      @response ||= ShareNotify::SearchResponse.new(
        share.post(GenericFileToShareJSONService.new(object, delete: true).json)
      )
    end

    def notification_job
      if response.status == 201
        ShareNotifyDeleteEventJob.new(generic_file.id, generic_file.depositor)
      else
        report_errors
      end
    end

    def report_errors
      Rails.logger.error(
        "Deleting file #{object.id} from SHARE Notify failed with #{response.status}. Response was #{response.response}"
      )
      ShareNotifyDeleteFailureEventJob.new(generic_file.id, generic_file.depositor)
    end
end
