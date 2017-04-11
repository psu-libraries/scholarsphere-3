# frozen_string_literal: true
# Use this file to easily define all of your cron jobs.
#
# NOTE: If you want the cronjob to run only on one machine, use :job for the roles
#       otherwise, the :app role will run the cronjob on every server!
set :output, "#{path}/log/wheneveroutput.log"

every :day, at: "12:00am", roles: [:app] do
  command "/scholarsphere/bin/whenever_generate_sitemap.sh"
end

every :day, at: "7:00am", roles: [:job] do
  rake 'share:files'
end

every :day, at: "12:20am", roles: [:job] do
  command "/scholarsphere/bin/whenever_audit_repository.sh"
end

every :day, at: "1:00 am", roles: [:job] do
  command "#{path}/config/cronjobs/compare_solr.bash"
end

every :day, at: "3:00 am", roles: [:job] do
  command "#{path}/config/cronjobs/update_user_stats.bash"
end

every :monday, at: "6:00 am", roles: [:job] do
  command "#{path}/config/cronjobs/send_weekly_stats.bash"
end

every 60.minutes, roles: [:app] do
  command "#{path}/config/cronjobs/temp_file_clean.bash"
end

every 10.minutes, roles: [:job] do
  command "#{path}/config/cronjobs/resque-cleanup.bash"
end

# Learn more: http://github.com/javan/whenever
