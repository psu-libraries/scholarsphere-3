# frozen_string_literal: true

class UserStatsNotificationJob < ApplicationJob
  def perform(id:, start_date:, end_date:)
    user = User.find(id)
    return unless PsuDir::LdapUser.check_ldap_exist!(user.login)

    UserMailer.user_stats_email(
      user_email: user.email,
      start_date: start_date,
      end_date: end_date
    ).deliver_now
  end
end
