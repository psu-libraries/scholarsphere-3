# config valid only for Capistrano 3.1
lock '3.2.1'

# application and repo settings
set :application, 'scholarsphere'
set :repo_url, "https://github.com/psu-stewardship/#{fetch(:application)}.git"

# default branch is :master
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "develop"

# default user and deployment location
set :user, "deploy"
set :deploy_to, "/opt/heracles/deploy/#{fetch(:application)}"
set :use_sudo, false

# ssh key settings
set :ssh_options, {
    keys: [File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")],
    forward_agent: true,
    #auth_methods: %w(password)
    #keys: %w(/home/rlisowski/.ssh/id_rsa),  
}

# rbenv settings
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp # read from file above
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec" # rbenv settings
set :rbenv_map_bins, %w{rake gem bundle ruby rails} # map the following bins
set :rbenv_roles, :all # default value

# rails settings, NOTE: Task is wired into event stack
set :rails_env, 'production'

# whenever settings, NOTE: Task is wired into event stack
set :whenever_identifier, -> {"#{fetch(:application)}_#{fetch(:stage)}"}
set :whenever_roles, [:app, :job]

# git for source control
set :scm, :git
set :git_strategy, Capistrano::Git::SubmoduleStrategy

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
#set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{log}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5, setting to 7
set :keep_releases, 7


# Apache namespace to control apache
namespace :apache do
 [:stop, :start, :restart, :reload].each do |action|
 desc "#{action.to_s.capitalize} Apache"
  task action do
   on roles(:web) do
    execute "sudo service httpd #{action.to_s}"
   end
  end
 end
end

namespace :deploy do
  
  # Link the appropriate configuration files based on application, stage, and release path
  desc "Link shared files"
  task :symlink_shared do
  on roles(:web) do
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/database.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/devise.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/fedora.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/hydra-ldap.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/newrelic.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/redis.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/solr.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/analytics.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/ga-privatekey.p12 #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/browse_everything_providers.yml #{fetch(:release_path)}/config/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/secret_token.rb #{fetch(:release_path)}/config/initializers/"
    execute "ln -sf /dlt/#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:application)}/sufia-secret.rb #{fetch(:release_path)}/config/initializers/"
    execute "ln -sf /dlt/#{fetch(:application)}/upload_#{fetch(:stage)}/uploads #{fetch(:release_path)}/public/"
    execute "ln -sf /dlt/#{fetch(:application)}/shared_#{fetch(:stage)}/public/sitemap.xml #{fetch(:release_path)}/public/sitemap.xml"
    end
  end
  after 'deploy:symlink:shared', :symlink_shared 

  # Resolarize objects
  desc "Re-solrize objects"
  task :resolrize do
   on roles(:solr) do
    within release_path do
     with rails_env: fetch(:rails_env) do
      execute :rake, "#{fetch(:application)}:resolrize"
     end
   end
  end
 end
 after :migrate, :resolrize

 # Restart resque-pool.
 desc "Restart resque-pool"
 task :resquepoolrestart do
  on roles(:app) do
    execute :sudo,  "/sbin/service resque_pool restart"
  end
 end
 before :restart, :resquepoolrestart

 # Queue sitemap.xml to be regenerated
 desc "Queue sitemap.xml to be generated"
 task :sitemapxml do
  on roles(:job)  do
   within release_path do
    with rails_env: fetch(:rails_env) do
     execute :rake, "#{fetch(:application)}:sitemap_queue_generate" 
    end
   end
  end
 end
 after :resquepoolrestart, :sitemapxml

 # Removes resque on the main server
 desc "Remove resque on the main server"
 task :remove_resque do
  on roles(:solr) do
   within release_path do
    execute "rm #{fetch(:release_path)}/config/resque-pool.yml"
   end
  end
 end
 after :symlink_shared, :remove_resque

 # Restart the application
 desc 'Restart application'
 task :restart do
  on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
  end
 end
 #after :publishing, :restart 
 after :restart, "passenger:warmup" 
end
