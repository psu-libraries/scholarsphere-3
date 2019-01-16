# frozen_string_literal: true

class UserStatsImporter
  attr_reader :view_report, :download_report

  def initialize(start_date, end_date = 1.day.ago)
    @view_report = GoogleAnalytics::ViewReport.new(start_date, end_date)
    @download_report = GoogleAnalytics::DownloadReport.new(start_date, end_date)
  end

  def import
    gather_view_stats
    gather_download_stats
    tally_user_results
  end

  def gather_view_stats
    works = process_statistic_list(view_report.work_page_views, WorkViewStat).uniq
    remove_zeros(works, WorkViewStat, 'work_id', view_field: :work_views)
    file_sets = process_statistic_list(view_report.file_set_page_views, FileViewStat).uniq
    remove_zeros(file_sets, FileViewStat, 'file_id', view_field: :views)
  end

  def gather_download_stats
    process_statistic_list(download_report.file_set_downloads, FileDownloadStat)
    process_statistic_list(download_report.work_downloads, FileDownloadStat, :get_download_statistic_object)
  end

  def tally_user_results
    User.find_each do |user|
      begin
        test_stats = GoogleAnalytics::UserStatisticReport.new(user).call
        create_or_update_user_stats(test_stats, user)
      rescue StandardError => e
        puts "Error with User: #{e.inspect}"
      end
    end
  end

  private

    def process_statistic_list(list, stat_class, object_lookup_method = :lookup_object)
      return [] if list.blank?

      list.map do |event|
        safe_method_call("Error finding object for event #{event}", :find_event_object, event, object_lookup_method) do |object|
          create_or_update_object_stat(event, translate_user_login_to_db_id(object.depositor),
                                       object, stat_class)
        end
      end
    end

    def remove_zeros(object_ids, stat_class, id_field, view_field:)
      object_ids.each do |object_id|
        stats = stat_class.where(id_field => object_id).order(:date)
        stats = stats.drop(1)
        middle_zeros = stats[0...-1].select { |stat| stat.send(view_field).zero? }
        middle_zeros.each(&:destroy)
      end
    end

    def get_download_statistic_object(id)
      work = lookup_object(id)
      work.file_sets.first
    end

    def path_to_id(page_path)
      page_path.split('/').last.split('?').first
    end

    def safe_method_call(error_message, method, *method_args)
      object = send(method, *method_args)
      yield object if block_given?
      object.id
    rescue StandardError => e
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

    # This was copied from Sufia::UserStatImporter to avoid having to inherit the entire class
    def create_or_update_user_stats(stats, user)
      stats.each do |date_string, data|
        date = Time.zone.parse(date_string)

        user_stat = UserStat.where(user_id: user.id, date: date).first_or_initialize(user_id: user.id, date: date)

        user_stat.file_views = data.fetch(:views, 0)
        user_stat.file_downloads = data.fetch(:downloads, 0)
        user_stat.work_views = data.fetch(:work_views, 0)
        user_stat.save!
      end
    end
end
