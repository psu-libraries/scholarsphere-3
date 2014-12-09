# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"

every :day, at: "12:00am", roles: [:app] do   
  command "/dlt/scholarsphere/bin/whenever_generate_sitemap.sh"
end

every :day, at: "12:20am", roles: [:app] do   
  command "/dlt/scholarsphere/bin/whenever_audit_repository.sh"
end

every :day, at: "1:00 am", roles: [:job] do
  command "#{path}/config/cronjobs/compare_solr.bash"
end

every :day, at: "3:00 am", roles: [:job] do
  command "#{path}/config/cronjobs/update_user_stats.bash"
end

every 60.minutes, roles: [:app] do
  command "#{path}/config/cronjobs/temp_file_clean.bash"
end

# Learn more: http://github.com/javan/whenever
