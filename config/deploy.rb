# Example Usage:
#   deploy to staging: cap staging deploy
#   deploy a specific branch to qa: cap -s branch=cappy qa deploy
#   deploy a specific revision to staging: cap -s revision=c9800f1 staging deploy
#   deploy a specific tag to production: cap -s tag=my_tag production deploy
#   keep only the last 3 releases on staging: cap -s keep_releases=3 staging deploy:cleanup

require 'bundler/capistrano'
require 'capistrano-rbenv'
require 'capistrano/ext/multistage'
require 'whenever/capistrano'
require 'capistrano-notification'

set :application, "scholarsphere"
set :whenever_command, "bundle exec whenever"

set :scm, :git
set :deploy_via, :remote_cache
set :repository,  "https://github.com/psu-stewardship/#{application}.git"

set :deploy_to, "/opt/heracles/deploy/#{application}"
set :user, "deploy"
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")]
set :use_sudo, false
default_run_options[:pty] = true

set :rbenv_ruby_version, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp
set :rbenv_setup_shell, false

notification.irc do |irc|
  irc.user    'cappy'
  irc.host    'chat.freenode.net'
  irc.channel '#scholarsphere'
  irc.message { "[#{irc.user}] #{local_user} deployed #{application} to #{stage}" }
end

# override default restart task for apache passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

# insert new task to symlink shared files
namespace :deploy do
  desc "Link shared files"
  task :symlink_shared do
    run <<-CMD.compact
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/database.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/devise.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/fedora.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/hydra-ldap.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/newrelic.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/redis.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/solr.yml #{release_path}/config/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/secret_token.rb #{release_path}/config/initializers/ &&
    ln -sf /dlt/#{application}/config_#{stage}/#{application}/sufia-secret.rb #{release_path}/config/initializers/
    CMD
  end
end
before "deploy:finalize_update", "deploy:symlink_shared"

# Always run migrations.
after "deploy:update_code", "deploy:migrate"

# Resolrize.
namespace :deploy do
  desc "Re-solrize objects"
  task :resolrize, roles: :solr do
    run <<-CMD.compact
    cd -- #{latest_release} &&
    RAILS_ENV=#{rails_env.to_s.shellescape} #{rake} #{application}:resolrize
    CMD
  end
end
after "deploy:migrate", "deploy:resolrize"

# Restart resque-pool.
namespace :deploy do
  desc "restart resque-pool"
  task :resquepoolrestart do
    run "sudo /sbin/service resque_pool restart"
  end
end
before "deploy:restart", "deploy:resquepoolrestart"

# config/deploy/_passenger.rb hooks.
after "rbenv:setup", "passenger:install"
after "deploy:restart", "passenger:warmup"

# Keep the last X number of releases.
set :keep_releases, 5
#after "passenger:warmup", "deploy:cleanup"

# end
