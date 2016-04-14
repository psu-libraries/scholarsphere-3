# frozen_string_literal: true
class ShareNotifyJob < ActiveJob::Base

  attr_reader :work

  def perform(work)
    @work = work
    return if unshareable? || work.share_notified?
    notification_job
  end

  def unshareable?
    ResourceFilteredList.new(
      PublicFilteredList.new([work]).filter
    ).filter.empty?
  end

  private

    def share
      @share ||= ShareNotify::API.new
    end

    def response
      @response ||= ShareNotify::SearchResponse.new(
        share.post(GenericWorkToShareJSONService.new(work).json)
      )
    end

    def notification_job
      if response.status == 201
        ShareNotifySuccessEventJob.perform_now(work, depositor)
      else
        report_errors
      end
    end

    def report_errors
      Rails.logger.error(
        "Posting file #{work.id} to SHARE Notify failed with #{response.status}. Response was #{response.response}"
      )
      ShareNotifyFailureEventJob.perform_now(work, depositor)
    end

    def depositor
      User.find_by_login(work.depositor)
    end
end
