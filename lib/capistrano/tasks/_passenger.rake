# Passenger.
namespace :passenger do
  desc "install (or upgrade) passenger gem and apache module"
  task :install do
   on roles(:web)  do
    passenger_token = capture('cat /dlt/scholarsphere/config_global/passenger/passenger-enterprise-download-token')
    execute "RBENV_VERSION=#{fetch(:rbenv_ruby)}"
    execute "RBENV_VERSION=#{fetch(:rbenv_ruby)} gem install --source https://download:#{passenger_token}@www.phusionpassenger.com/enterprise_gems/ passenger-enterprise-server --no-ri --no-rdoc -v 4.0.58"
    execute "RBENV_VERSION=#{fetch(:rbenv_ruby)} rbenv rehash"
    execute "RBENV_VERSION=#{fetch(:rbenv_ruby)} passenger-install-apache2-module --auto"
    invoke "passenger:update_config"    
   end
  end
  #after "deploy:bundle", "passenger:install"

  desc "Update passenger conf file"
  task :update_config do
   on roles(:web) do
    version = 'ERROR' # default

    # passenger (2.X.X, 1.X.X)
    execute ("RBENV_VERSION=#{fetch(:rbenv_ruby)} gem list | grep passenger") do |ch, stream, data|
      version = data.sub(/passenger \(([^,]+).*?\)/,"\\1").strip
    end

   puts "passenger version #{version} configured"
   # Note: First line is overwrite not append
   execute('echo "# This is created by capistrano. Refer to passenger:update_config" >  /opt/heracles/deploy/.passenger.tmp')
   # Note: First line is overwrite not append     
   execute('echo "PassengerSpawnMethod smart" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerPoolIdleTime 1000" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "RailsAppSpawnerIdleTime 0" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerMaxRequests 5000" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerMinInstances 3" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerMaxPoolSize 8" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerDataBufferDir /opt/heracles/deploy/passenger" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "PassengerInstanceRegistryDir /opt/heracles/deploy/passenger" >>  /opt/heracles/deploy/.passenger.tmp')

   execute('echo "#PassengerLogLevel 3" >>  /opt/heracles/deploy/.passenger.tmp')
   execute('echo "#PassengerDebugLogFile /var/log/httpd/passenger_debug.log" >>  /opt/heracles/deploy/.passenger.tmp')

   execute "RBENV_VERSION=#{fetch(:rbenv_ruby)} passenger-install-apache2-module --snippet >>  /opt/heracles/deploy/.passenger.tmp"
   
   execute "mkdir -p #{shared_path}/passenger"
   execute "sudo /bin/mv /opt/heracles/deploy/.passenger.tmp /etc/httpd/conf.d/passenger.conf"
   execute "sudo /sbin/service httpd restart"
   invoke "passenger:warmup"
   end
  end

  desc "warm up passenger"
  task :warmup do
   on roles(:web) do
   puts "do something"
   #execute "curl -s -k --head https://$(hostname -f)"
   # execute "curl -s -k -o /dev/null --head https://$(hostname -f)"
   end
  end
end

# end
