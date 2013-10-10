# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"

every :day, :at => "12:00am" do   
  command "/dlt/scholarsphere/bin/whenever_generate_sitemap.sh"
end

every :day, :at => "12:20am" do   
  command "/dlt/scholarsphere/bin/whenever_audit_repository.sh"
end


# Learn more: http://github.com/javan/whenever
