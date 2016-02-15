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
    stats.recent_users.count
  end

  def total_uploads
    documents_by_permission[:total]
  end

  def total_public_uploads
    documents_by_permission[:public]
  end

  def total_registered_uploads
    documents_by_permission[:registered]
  end

  def total_private_uploads
    documents_by_permission[:private]
  end

  private

    def stats
      @stats ||= SystemStats.new(5, start_datetime.to_s, end_datetime.to_s)
    end

    def documents_by_permission
      @documents_by_permission ||= stats.document_by_permission
    end
end
