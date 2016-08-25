# frozen_string_literal: true
lock '3.5.0'

# application and repo settings
set :application, 'scholarsphere'
set :repo_url, "https://github.com/psu-stewardship/#{fetch(:application)}.git"
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"

# default user and deployment location
set :user, "deploy"
set :deploy_to, "/opt/heracles/deploy/#{fetch(:application)}"
set :use_sudo, false

# ssh key settings
set :ssh_options, {
  keys: [File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")],
  forward_agent: true
}

# rbenv settings
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp # read from file above
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec" # rbenv settings
set :rbenv_map_bins, %w(rake gem bundle ruby rails) # map the following bins
set :rbenv_roles, :all # default value

# set passenger to just the web servers
set :passenger_roles, :web

# rails settings, NOTE: Task is wired into event stack
set :rails_env, 'production'

# whenever settings, NOTE: Task is wired into event stack
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, [:app, :job]

set :scm, :git
set :log_level, :debug
set :pty, true

# Airbrussh options
set :format_options, command_output: false

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/devise.yml',
  'config/fedora.yml',
  'config/fedora3.yml',
  'config/hydra-ldap.yml',
  'config/newrelic.yml',
  'config/redis.yml',
  'config/solr.yml',
  'config/analytics.yml',
  'config/share_notify.yml',
  'config/blacklight.yml',
  'config/ga-privatekey.p12',
  'config/browse_everything_providers.yml',
  'config/arkivo.yml',
  'config/zotero.yml',
  'config/secrets.yml',
  'public/sitemap.xml',
  'public/robots.txt',
  'config/initializers/arkivo_constraint.rb',
  'config/initializers/sufia-secret.rb'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/derivatives',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads'
)

# Default value for keep_releases is 5
set :keep_releases, 7

# Default value for keep_releases is 5, setting to 7
set :keep_releases, 7

# Apache namespace to control apache
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action do
      on roles(:web) do
        execute "sudo service httpd #{action}"
      end
    end
  end
end

namespace :deploy do
  desc "Re-solrize objects"
  task :resolrize do
    on roles(:job) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "#{fetch(:application)}:resolrize"
        end
      end
    end
  end
  # Disable resolrization until after PCDM migration
  # after :migrate, :resolrize

  desc "Restart resque-pool"
  task :resquepoolrestart do
    on roles(:job) do
      execute "cd ~deploy/scholarsphere/current && ./script/restart_resque.sh production"
    end
  end
  after :published, :resquepoolrestart

  desc "Queue sitemap.xml to be generated"
  task :sitemapxml do
    on roles(:job) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "#{fetch(:application)}:sitemap_queue_generate"
        end
      end
    end
  end
  # Disabled, see psu-stewardship/scholarsphere#285
  # after :published, :sitemapxml

  # Passenger Capistrano Task
  # The passenger install task allows Chef to install Passenger now via Yum, but it allows Capistrano to maintain the file
  # as Ruby is updated on the system.  The PassengerDefaultRuby variable is set to system ruby by default from the Yum
  # install.  This will not work in our environment.
  # Passenger Install Task below defines the current ruby version
  # Adds it to temp file
  # then copies passenger configs to temp file.
  # Replaces all instances of PassengerRuby with proper version in temp file.
  # Replace passenger conf file with temp file.

  namespace :passenger do
    desc "Passenger Version Config Update"
    task :config_update do
      on roles(:web) do
        execute "mkdir --parents /opt/heracles/deploy/passenger"
        execute 'cd ~deploy/scholarsphere/current && echo -n "PassengerRuby " > ~deploy/passenger/passenger-ruby-version.cap   && rbenv which ruby >> ~deploy/passenger/passenger-ruby-version.cap'
        execute 'v_passenger_ruby=$(cat ~deploy/passenger/passenger-ruby-version.cap) &&    cp --force /etc/httpd/conf.d/phusion-passenger-default-ruby.conf ~deploy/passenger/passenger-ruby-version.tmp &&    sed -i -e "s|.*PassengerRuby.*|${v_passenger_ruby}|" ~deploy/passenger/passenger-ruby-version.tmp &&     sudo /bin/mv ~deploy/passenger/passenger-ruby-version.tmp /etc/httpd/conf.d/phusion-passenger-default-ruby.conf &&  sudo /sbin/service httpd restart'
      end
    end
  end
  after :published, "passenger:config_update"
end

# Used to keep x-1 instances of ruby on a machine.  Ex +4 leaves 3 versions on a machine.  +3 leaves 2 versions
namespace :rbenv_custom_ruby_cleanup do
  desc "Clean up old rbenv versions"
  task :purge_old_versions do
    on roles(:web) do
      execute 'ls -dt ~deploy/.rbenv/versions/*/ | tail -n +3 | xargs rm -rf'
    end
  end
  after "deploy:finishing", "rbenv_custom_ruby_cleanup:purge_old_versions"
end
