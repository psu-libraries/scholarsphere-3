# frozen_string_literal: true

module GoogleAnalytics
  class ViewReport
    attr_reader :start_date, :end_date

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def work_page_views
      @work_page_views ||= google_analytics_view_results.select { |result| result.pagePath.include?('generic_works') }
    end

    def file_set_page_views
      @file_set_page_views ||= google_analytics_view_results.select { |result| result.pagePath.include?('file_sets') }
    end

    private

      def google_analytics_view_results
        return @google_analytics_view_results if @google_analytics_view_results.present?

        profile = Sufia::Analytics.profile
        @google_analytics_view_results = Sufia::Pageview.results(profile, start_date: start_date, end_date: end_date, sort: :pagePath)
        @google_analytics_view_results.dimensions << :pagePath

        @google_analytics_view_results
      end
  end
end
