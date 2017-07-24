# frozen_string_literal: true
class ShareNotifySuccessEventJob < ContentEventJob
  def action
    'File was successfully sent to SHARE Notify'
  end
end
