# frozen_string_literal: true

module Scholarsphere::Migration
  class Statistics
    def self.call
      new.build
    end

    def build
      CSV.open('statistics.csv', 'wb') do |csv|
        works.map do |work|
          @file_set_ids = work.fetch('file_set_ids_ssim', [])

          # Write the view stats for the work
          combined_hash(work.id).map do |date, views|
            csv << [work.id, date, views]
          end

          # Write the downloads for each file in the work
          file_download_stats.map do |stat|
            csv << [stat.file_id, stat.date.iso8601, stat.downloads]
          end

          # Rest the file set ids for the next work
          @file_set_ids = nil
        end
      end
    end

    private

      # @note Only get the stats on the works that are presently in Scholarsphere
      def works
        ActiveFedora::SolrService
          .query('has_model_ssim:GenericWork', fl: ['id', 'file_set_ids_ssim'], rows: 10_000)
      end

      # @note Combine view counts from works and file sets into one statistic, grouped per unique date
      def combined_hash(work_id)
        work_views = work_view_stats(work_id)
        file_views = file_view_stats
        results = {}

        (work_views + file_views).flatten.sort_by(&:date).map do |stat|
          results[stat.date.iso8601] ||= 0
          results[stat.date.iso8601] += stat.views
        end

        results
      end

      def work_view_stats(id)
        WorkViewStat
          .select(:date, :work_views)
          .where(work_id: id)
          .where.not(work_views: 0)
          .map { |stat| OpenStruct.new(date: stat.date, views: stat.work_views) }
      end

      def file_view_stats
        @file_set_ids.map do |file_set_id|
          FileViewStat
            .select(:date, :views, :file_id)
            .where(file_id: file_set_id)
            .where.not(views: 0)
            .map { |stat| OpenStruct.new(date: stat.date, views: stat.views) }
        end.flatten
      end

      def file_download_stats
        @file_set_ids.map do |file_set_id|
          FileDownloadStat
            .select(:date, :downloads, :file_id)
            .where(file_id: file_set_id)
            .where.not(downloads: 0)
        end.flatten
      end
  end
end
