# frozen_string_literal: true
class ShareNotifyDeleteJob < ShareNotifyJob
  def perform(work)
    @work = work
    notification_job
  end

  # Allows us to cache the document before sending it to SHARE in case the
  # actual file is to be deleted.
  def document
    @document ||= GenericWorkToShareJSONService.new(work, delete: true).json
  end

  private

    def response
      @response ||= ShareNotify::SearchResponse.new(share.post(document))
    end

    def notification_job
      if response.status == 201
        ShareNotifyDeleteEventJob.perform_now(work, depositor)
      else
        report_errors
      end
    end

    def report_errors
      Rails.logger.error(
        "Deleting file #{work.id} from SHARE Notify failed with #{response.status}. Response was #{response.response}"
      )
      ShareNotifyDeleteFailureEventJob.perform_now(work, depositor)
    end
end
