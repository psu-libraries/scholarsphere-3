# frozen_string_literal: true

# Using Rails' to_prepare hook in config/application.rb, we can inject this module as
# Sufia::StatsUsagePresenter is loaded, and alter its existing behaviors without having to redefine
# the entire class.
module PrependedPresenters::StatsUsageBehavior
  private

    # @param [DateTime, String] date_str
    # @return [Time, nil]
    # Overrides Sufia::StatsUsagePresenter to convert DateTime objects to strings.
    def string_to_date(date_str)
      Time.zone.parse(date_str.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def to_flots(stats)
      stats = fill_in_missing_dates_with_zero(stats)
      super(stats)
    end

    def fill_in_missing_dates_with_zero(stats)
      return stats if stats.count < 2

      date_range_for_stats = date_range(stats)
      return stats if stats.count == date_range_for_stats.count

      complete_stats_for_range(date_range_for_stats, stats)
    end

    def date_range(stats)
      start_date = stats.first.date.to_date
      end_date = stats.last.date
      start_date..end_date
    end

    def complete_stats_for_range(date_range, stats)
      stats_class = stats.first.class

      date_range.map do |date|
        if stat_for_date?(stats.first, date)
          stats.shift
        else
          empty_stat(stats_class, date)
        end
      end
    end

    def stat_for_date?(stat, date)
      stat.date.to_date == date
    end

    def empty_stat(stat_class, date)
      stat_class.new(date: date, stat_class.cache_column => 0)
    end
end
