# frozen_string_literal: true
class ShareNotifyFailureEventJob < ContentEventJob
  def action
    "File could not be sent to SHARE Notify"
  end
end
