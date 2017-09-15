# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Load rake tasks for development and testing
unless Rails.env.production?
  Dir.glob(File.expand_path('../tasks/*.rake', __FILE__)).each do |f|
    load(f)
  end
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
end

ScholarSphere::Application.load_tasks
