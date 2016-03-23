# frozen_string_literal: true
class ShareNotifyDeleteFailureEventJob < ContentEventJob
  def action
    "File could not be marked for deletion from SHARE Notify"
  end
end
