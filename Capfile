# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require 'capistrano/rvm'
require 'capistrano/rbenv' #rbenv setup
require 'capistrano/rails' #rails (includes bundler, rails/assets and rails/migrations)
require 'whenever/capistrano' #whenever 
require 'capistrano/passenger' #passenger
require 'capistrano-resque'  #resque

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
# tasks included: passenger, checksum
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

# Enable tracing at all times
Rake.application.options.trace = true
Rake.application.options.backtrace = true
