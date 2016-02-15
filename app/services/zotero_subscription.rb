# frozen_string_literal: true
class ZoteroSubscription
  def self.call
    # get a list of the users with zotero ids and no arkivo subscription
    users = User.where.not(zotero_userid: nil).where(arkivo_subscription: nil)

    # send a subscription request for each
    users.each do |user|
      Rails.logger.info "Subscribing #{user.user_key} to arkivo"
      Sufia::Arkivo::CreateSubscriptionJob.new(user.user_key).run
    end
  end
end
