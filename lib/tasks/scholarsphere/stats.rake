# frozen_string_literal: true

namespace :scholarsphere do
  namespace :stats do
    desc 'Cache file view & download stats for all users'
    task :user_stats, [:start_date] => :environment do |_t, args|
      start_date = if args[:start_date].blank?
                     2.days.ago
                   else
                     Date.parse(args[:start_date])
                   end
      puts "importing stats from google for #{start_date} to #{1.day.ago}"
      importer = UserStatsImporter.new(start_date, 1.day.ago)
      importer.import
    end

    desc 'Notify users of their monthly stats'
    task notify: :environment do
      start_date = Date.today.last_month.beginning_of_month
      end_date = Date.today.last_month.end_of_month
      UserStat.where(date: start_date..end_date).map(&:user_id).uniq.map do |id|
        UserStatsNotificationJob.perform_later(id: id, start_date: start_date, end_date: end_date)
      end
    end
  end
end
