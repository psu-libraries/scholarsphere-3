namespace :scholarsphere do
  namespace :stats do

    desc "Cache file view & download stats for all users"
    task :user_stats => :environment do

      # These must be required here so that Pageview and Download classes will properly load Legato's
      # additional methods. In a complete Rails production environment, they are eager-loaded, but
      # for rake tasks they do not appear to be.
      require 'legato'
      require 'sufia/pageview'
      require 'sufia/download'

      importer = Sufia::UserStatImporter.new(verbose: true, logging: true, delay_secs: 1.0, number_of_retries: 5)
      importer.import
    end

  end
end
