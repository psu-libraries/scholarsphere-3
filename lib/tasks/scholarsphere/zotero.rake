namespace :scholarsphere do
  namespace :zotero do

    desc "Subscribe zotero users for arikovo Subscriptions"
    task :arkivo_subscribe => :environment do
      begin
        ZoteroSubscription.call
        puts "Completed zotero subscription update.  Check log file for more details"
      rescue Faraday::ConnectionFailed => e
        puts "Can not connect to arkivo.  Please be certain arkivo the server is running. Error Received: #{e.message}"
      end
    end
  end
end
