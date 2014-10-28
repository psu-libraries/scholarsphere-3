# Passenger.
namespace :passenger do
  desc "install (or upgrade) passenger gem and apache module"
  task :install do
   on roles(:web)  do
    execute "gem install passenger --no-ri --no-rdoc"
    execute "rbenv rehash"
    execute "passenger-install-apache2-module --auto"
    invoke "passenger:update_config"
   end
  end
  #after "deploy:bundle", "passenger:install"

  desc "Update passenger conf file"
  task :update_config do
   on roles(:web) do
    version = 'ERROR' # default

    # passenger (2.X.X, 1.X.X)
    execute ("gem list | grep passenger") do |ch, stream, data|
      version = data.sub(/passenger \(([^,]+).*?\)/,"\\1").strip
    end

    puts "passenger version #{version} configured"

    passenger_config =<<-EOF
        # This is created by capistrano. Refer to passenger:update_config

        PassengerSpawnMethod smart
        PassengerPoolIdleTime 1000
        RailsAppSpawnerIdleTime 0
        PassengerMaxRequests 5000
        PassengerMinInstances 3

        #PassengerLogLevel 3
        #PassengerDebugLogFile /var/log/httpd/passenger_debug.log

        PassengerTempDir /opt/heracles/deploy/passenger
        EOF

        puts passenger_config, "/opt/heracles/deploy/.passenger.tmp"
        execute "passenger-install-apache2-module --snippet >>  /opt/heracles/deploy/.passenger.tmp"
        execute "mkdir -p #{shared_path}/passenger"
        execute "sudo /bin/mv /opt/heracles/deploy/.passenger.tmp /etc/httpd/conf.d/passenger.conf"
        execute "sudo /sbin/service httpd restart"
        invoke "passenger:warmup"
   end
  end

  desc "warm up passenger"
  task :warmup do
   on roles(:web) do
   execute "curl -s -k --head https://$(hostname -f)"
   # execute "curl -s -k -o /dev/null --head https://$(hostname -f)"
   end
  end
end

# end
