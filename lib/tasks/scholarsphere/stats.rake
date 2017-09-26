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
      importer = UserStatsImporter.new(start_date, 1.day.ago, verbose: true, logging: true, delay_secs: 1.0, number_of_retries: 5)
      importer.import
    end
  end
end
