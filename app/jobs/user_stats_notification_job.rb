# frozen_string_literal: true

class UserStatsNotificationJob < ApplicationJob
  def perform(id:, start_date:, end_date:)
    user = User.find(id)
    return if user.opt_out_stats_email || !PsuDir::LdapUser.check_ldap_exist!(user.login)

    UserMailer.user_stats_email(
      user: user,
      start_date: start_date,
      end_date: end_date
    ).deliver_now
  end
end
