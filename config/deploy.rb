# frozen_string_literal: true

# lock '3.6'

# Set assets roles to occur on jobs as well as web
set :assets_role, [:web, :job]

# application and repo settings
set :application, 'scholarsphere'
set :repo_url, "https://github.com/psu-stewardship/#{fetch(:application)}.git"
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'develop'

# default user and deployment location
set :user, 'deploy'
set :deploy_to, "/opt/heracles/deploy/#{fetch(:application)}"
set :use_sudo, false

# ssh key settings
set :ssh_options, {
  keys: [File.join(ENV['HOME'], '.ssh', 'id_deploy_rsa')],
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

# Settings for whenever gem that updates the crontab file on the server
# See schedule.rb for details
set :whenever_roles, [:app, :job, :prod_job]

set :log_level, :debug
set :pty, true

# Airbrussh options
set :format_options, command_output: false

# Default value for :linked_files is []
# Example link: ln -s /opt/heracles/deploy/scholarsphere/shared/config/redis.yml /opt/heracles/deploy/scholarsphere/current/config/redis.yml
set :linked_files, fetch(:linked_files, []).push(
  'config/analytics.yml',
  'config/application.yml',
  'config/arkivo.yml',
  'config/blacklight.yml',
  'config/browse_everything_providers.yml',
  'config/database.yml',
  'config/devise.yml',
  'config/fedora.yml',
  'config/fedora3.yml',
  'config/ga-privatekey.p12',
  'config/hydra-ldap.yml',
  'config/initializers/arkivo_constraint.rb',
  'config/initializers/qa.rb',
  'config/initializers/sufia6.rb',
  'config/newrelic.yml',
  'config/redis.yml',
  'config/secrets.yml',
  'config/share_notify.yml',
  'config/solr.yml',
  'config/zotero.yml',
  'public/robots.txt',
  'public/sitemap.xml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'public/system',
  'public/uploads',
  'public/binaries',
  'public/zip',
  'tmp/cache',
  'tmp/pids',
  'tmp/sockets',
  'tmp/uploads',
  'vendor/bundle'
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

namespace :rbenv do
  desc 'Overrides task in capistrano-rbenv-install to install the correct version of the bundler gem'
  task install_bundler: ['rbenv:map_bins'] do
    on roles fetch(:rbenv_roles) do
      next if test :gem, :query, "--quiet --installed --name-matches ^bundler (#{Bundler::VERSION})$"

      execute :gem, :install, :bundler, "--quiet --no-document --version #{Bundler::VERSION}"
    end
  end
end

namespace :deploy do
  desc 'Verify yaml configuration files are present and contain the correct keys'
  task :check_configs do
    on roles(:all) do
      within release_path do
        execute :rake, 'scholarsphere:config:check', 'RAILS_ENV=production'
      end
    end
  end
  after :updated, :check_configs

  desc 'set up the shared directory to have the symbolic links to the appropriate directories shared between servers'
  task :symlink_shared_directories do
    on roles(:web, :job) do
      execute "ln -sf /#{fetch(:application)}/upload_#{fetch(:stage)}_new/uploads/ /opt/heracles/deploy/scholarsphere/shared/tmp/"
      execute "ln -sf /#{fetch(:application)}/upload_#{fetch(:stage)}_new/uploads /opt/heracles/deploy/scholarsphere/shared/public/"
      execute "ln -sf /#{fetch(:application)}/shared_#{fetch(:stage)}_new/public/robots.txt /opt/heracles/deploy/scholarsphere/shared/public/robots.txt"
      execute "ln -sf /#{fetch(:application)}/shared_#{fetch(:stage)}_new/public/sitemap.xml /opt/heracles/deploy/scholarsphere/shared/public/sitemap.xml"
      execute "ln -sf /#{fetch(:application)}/shared_#{fetch(:stage)}_new/public/system/ /opt/heracles/deploy/scholarsphere/shared/public/"
      execute "ln -sf /#{fetch(:application)}/shared_#{fetch(:stage)}_new/public/zip/ /opt/heracles/deploy/scholarsphere/shared/public/"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}_new/scholarsphere/ /opt/heracles/deploy/scholarsphere/shared/config"
      execute "ln -sf /#{fetch(:application)}/binaries_#{fetch(:stage)} /opt/heracles/deploy/scholarsphere/shared/public/binaries"
    end
  end
  before 'deploy:check:linked_dirs', :symlink_shared_directories

  desc 'Restart resque-pool'
  task :resquepoolrestart do
    on roles(:job) do
      execute 'sudo /bin/systemctl restart resque'
    end
  end
  after :published, :resquepoolrestart

  desc 'Re-solrize objects'
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
  after :resquepoolrestart, :resolrize

  desc 'Queue sitemap.xml to be generated'
  task :sitemapxml do
    on roles(:job) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "#{fetch(:application)}:sitemap_queue_generate"
        end
      end
    end
  end
  # Re-enabled, see psu-stewardship/scholarsphere#285
  after :published, :sitemapxml

  desc 'Compile assets on for selected server roles'
  task :roleassets do
    on roles(:job) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'assets:precompile '
        end
      end
    end
  end
  after :migrate, :roleassets

  desc 'Create a symlink to assets used by Resque'
  task :symlink_resque_assets do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'resque:assets'
        end
      end
    end
  end
  after :roleassets, :symlink_resque_assets
end

# Used to keep x-1 instances of ruby on a machine.  Ex +4 leaves 3 versions on a machine.  +3 leaves 2 versions
namespace :rbenv_custom_ruby_cleanup do
  desc 'Clean up old rbenv versions'
  task :purge_old_versions do
    on roles(:web) do
      execute 'ls -dt ~deploy/.rbenv/versions/*/ | tail -n +3 | xargs rm -rf'
    end
  end
  after 'deploy:finishing', 'rbenv_custom_ruby_cleanup:purge_old_versions'
end

# newrelic deployment markers
after 'deploy:updated', 'newrelic:notice_deployment'

desc 'send newrelic java deployment markers'
task :nrdm_java do
  on roles(:web) do
    execute 'java -jar /opt/heracles/newrelic/newrelic.jar deployment'
  end
end
# after 'newrelic:notice_deployment', :nrdm_java
