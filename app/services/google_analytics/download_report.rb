# frozen_string_literal: true

module GoogleAnalytics
  class DownloadReport
    attr_reader :start_date, :end_date

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def work_downloads
      initialize_page_downloads
      @work_downloads
    end

    def file_set_downloads
      initialize_page_downloads
      @file_set_downloads
    end

    private

      def google_analytics_download_results
        return @google_analytics_download_results if @google_analytics_download_results.present?

        profile = Sufia::Analytics.profile
        @google_analytics_download_results = Sufia::Download.results(profile, start_date: start_date, end_date: end_date, sort: :pagePath)
        @google_analytics_download_results.dimensions << :pagePath

        @google_analytics_download_results
      end

      def initialize_page_downloads
        return if @page_downloads_initialized

        google_analytics_download_results.each do |page_download|
          classify_download(page_download)
        end
        @page_downloads_initialized = true
      end

      def classify_download(page_download)
        @work_downloads ||= []
        @file_set_downloads ||= []
        if page_is_work_download?(page_download)
          @work_downloads << page_download
        else
          @file_set_downloads << page_download
        end
      rescue ActiveFedora::ObjectNotFoundError => e
        puts "Error loading object for download: #{page_download}, error: #{e}"
      end

      def page_is_work_download?(page_download)
        id = path_to_id(page_download.pagePath)
        lookup_object(id).class == GenericWork
      end

      def path_to_id(page_path)
        page_path.split('/').last
      end

      def lookup_object(id)
        @cache_last_object ||= GenericWork.new
        if id != @cache_last_object.id
          @cache_last_object = ActiveFedora::Base.find(id)
        end
        @cache_last_object
      end
  end
end
