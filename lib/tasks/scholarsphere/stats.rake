namespace :scholarsphere do
  namespace :stats do

    desc "Cache file view & download stats for all users"
    task :user_stats => :environment do
      require 'sufia/models/stats/user_stat_importer'
      importer = Sufia::UserStatImporter.new(verbose: true, logging: true, delay_secs: 1.0, number_of_retries: 5)
      importer.import
    end

  end
end
