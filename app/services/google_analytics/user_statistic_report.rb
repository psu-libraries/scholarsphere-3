# frozen_string_literal: true

module GoogleAnalytics
  class UserStatisticReport < Sufia::UserStatImporter
    attr_reader :user, :stats

    def initialize(user)
      @user = user
      @stats = {}
    end

    def call
      tally_stats_for_user_files
      tally_stats_for_user_works
      stats
    end

    private

      def tally_stats_for_user_files
        file_ids_for_user(user).each do |file_id|
          file_set = FileSet.find(file_id)
          tally_object_stat(file_set, FileDownloadStat, :downloads)
          tally_object_stat(file_set, FileViewStat, :views)
        end
      end

      def tally_stats_for_user_works
        work_ids_for_user(user).each do |work_id|
          tally_object_stat(GenericWork.find(work_id), WorkViewStat, :work_views)
        end
      end

      def tally_object_stat(object, statistic_class, tally_key)
        results = statistic_class.send(:statistics_for, object).order(date: :asc)
        tally_results(results, tally_key, stats) if results.present?
      end
  end
end
