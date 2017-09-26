# frozen_string_literal: true

class ShareNotifyDeleteEventJob < ContentEventJob
  def action
    'File was successfully marked for deletion from SHARE Notify'
  end
end
