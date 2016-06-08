# frozen_string_literal: true
class StatsPresenter
  attr_reader :start_datetime, :end_datetime

  def initialize(start_datetime, end_datetime)
    @start_datetime = start_datetime
    @end_datetime = end_datetime
  end

  def single_day?
    start_date == end_date
  end

  def start_date
    start_datetime.to_date
  end

  def end_date
    end_datetime.to_date
  end

  def date_str
    if single_day?
      start_date.to_s
    else
      "#{start_date}_#{end_date}"
    end
  end

  def terms
    [:total_users, :total_uploads, :total_public_uploads, :total_registered_uploads, :total_private_uploads]
  end

  def total_users
    system_stats.users_count
  end

  def total_uploads
    work_stats.by_permission.fetch(:total, 0)
  end

  def total_public_uploads
    work_stats.by_permission.fetch(:public, 0)
  end

  def total_registered_uploads
    work_stats.by_permission.fetch(:registered, 0)
  end

  def total_private_uploads
    work_stats.by_permission.fetch(:private, 0)
  end

  private

    def work_stats
      @work_stats ||= Sufia::Statistics::Works::Count.new(start_datetime, end_datetime)
    end

    def system_stats
      @system_stats ||= Sufia::Statistics::SystemStats.new(5, start_datetime, end_datetime)
    end
end
