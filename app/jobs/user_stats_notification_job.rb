# frozen_string_literal: true

class UserStatsNotificationJob < ApplicationJob
  def perform(id:, start_date:, end_date:)
    user = User.find(id)
    return unless PsuDir::LdapUser.check_ldap_exist!(user.login) && User.where(opt_out_stats_email: true)

    UserMailer.user_stats_email(
      user: user,
      start_date: start_date,
      end_date: end_date
    ).deliver_now
  end
end
