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
end
