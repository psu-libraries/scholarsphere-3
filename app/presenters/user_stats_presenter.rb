# frozen_string_literal: true

class UserStatsPresenter
  attr_accessor :start_date, :end_date, :user

  def initialize(start_date:, end_date:, user:)
    @start_date = start_date
    @end_date = end_date
    @user = user
  end

  def file_downloads
    @file_downloads ||= UserStat.where(user_id: user.id).where(date: start_date..end_date).sum(:file_downloads)
  end

  def total_files
    @total_files ||= FileSet.all.where(creator_tesim: user.login).count
  end
end
