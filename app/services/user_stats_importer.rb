# frozen_string_literal: true

class UserStatsImporter < Sufia::UserStatImporter
  attr_reader :start_date, :end_date, :view_report, :download_report

  def initialize(start_date, end_date = 1.day.ago, options = {})
    super(options)
    @start_date = start_date
    @end_date = end_date
    @view_report = GoogleAnalytics::ViewReport.new(start_date, end_date)
    @download_report = GoogleAnalytics::DownloadReport.new(start_date, end_date)
  end

  def import
    gather_view_stats
    gather_download_stats
    tally_user_results
  end

  def gather_view_stats
    process_statistic_list(view_report.work_page_views, WorkViewStat)
    process_statistic_list(view_report.file_set_page_views, FileViewStat)
  end

  def gather_download_stats
    process_statistic_list(download_report.file_set_downloads, FileDownloadStat)
    process_statistic_list(download_report.work_downloads, FileDownloadStat, :get_download_statistic_object)
  end

  def tally_user_results
    sorted_users.each do |user|
      stats = {}
      stats = tally_stats_for_user_files(user, stats)
      stats = tally_stats_for_user_works(user, stats)
      create_or_update_user_stats(stats, user)
    end
  end

  private

    def process_statistic_list(list, stat_class, object_lookup_method = :lookup_object)
      return if list.blank?

      list.each do |event|
        safe_method_call("Error finding object for event #{event}", :find_event_object, event, object_lookup_method) do |object|
          object = find_event_object(event, object_lookup_method)
          create_or_update_object_stat(event, translate_user_login_to_db_id(object.depositor),
                                       object, stat_class)
        end
      end
    end

    def tally_stats_for_user_files(user, stats)
      safe_method_call("Error find file ids for user: #{user} ", :file_ids_for_user, user) do |file_id_list|
        file_id_list.each do |file_id|
          safe_method_call("Error tallying Stats for FilesSet: #{file_id} ", :lookup_object, file_id) do |file_set|
            tally_file_set_download_stat(file_set, stats)
            tally_file_set_view_stat(file_set, stats)
          end
        end
      end
      stats
    end

    def tally_stats_for_user_works(user, stats)
      work_ids_for_user(user).each do |work_id|
        safe_method_call("Error tallying Stats for Work: #{work_id} ", :lookup_object, work_id) do |work|
          stats = tally_work_view_stat(work, stats)
        end
      end
      stats
    end

    def tally_work_view_stat(work, stats)
      view_stats = WorkViewStat.statistics_for(work).order(date: :asc)
      tally_results(view_stats, :work_views, stats) if view_stats.present?
      stats
    end

    def tally_file_set_view_stat(file_set, stats)
      view_stats = FileViewStat.statistics_for(file_set).order(date: :asc)
      stats = tally_results(view_stats, :views, stats) if view_stats.present?
      stats
    end

    def tally_file_set_download_stat(file_set, stats)
      download_stats = FileDownloadStat.statistics_for(file_set).order(date: :asc)
      stats = tally_results(download_stats, :downloads, stats) if download_stats.present?
      stats
    end

    def get_download_statistic_object(id)
      work = lookup_object(id)
      work.file_sets.first
    end

    def path_to_id(page_path)
      page_path.split('/').last
    end

    def safe_method_call(error_message, method, *method_args)
      object = send(method, *method_args)
      yield object if block_given?
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone, Errno::ECONNREFUSED => e
      puts "#{error_message} #{e.inspect}"
    end

    def lookup_object(id)
      @cache_last_object ||= GenericWork.new

      if id != @cache_last_object.id
        @cache_last_object = ActiveFedora::Base.find(id)
      end
      @cache_last_object
    end

    def find_event_object(event, object_lookup_method)
      send(object_lookup_method, path_to_id(event.pagePath))
    end

    def translate_user_login_to_db_id(login)
      user = User.find_by(login: login)
      user.id
    end

    def create_or_update_object_stat(event, user_db_id, object, stat_class)
      view_date = Date.parse(event[:date])
      old_stat = stat_class.statistics_for(object).where(date: view_date.beginning_of_day..view_date.end_of_day).first
      updated_stat = if !old_stat.nil?
                       old_stat.send("#{stat_class.cache_column}=".to_sym, event[stat_class.event_type])
                       old_stat
                     else
                       stat_class.build_for(object, date: view_date, stat_class.cache_column => event[stat_class.event_type], user_id: user_db_id)
                     end
      updated_stat.save
    end
end
