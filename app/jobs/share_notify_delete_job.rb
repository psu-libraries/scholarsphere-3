# frozen_string_literal: true
class ShareNotifyDeleteJob < ShareNotifyJob
  def run
    Sufia.queue.push(notification_job)
  end

  # Allows us to cache the document before sending it to SHARE in case the
  # actual file is to be deleted.
  def document
    @document ||= GenericFileToShareJSONService.new(object, delete: true).json
  end

  private

    def response
      @response ||= ShareNotify::SearchResponse.new(share.post(document))
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
