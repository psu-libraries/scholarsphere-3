require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'active_fedora/rake_support'

namespace :scholarsphere do
  desc "Run specs"
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = ['--color', '--backtrace']
  end

  desc "Run all feature tests"
  RSpec::Core::RakeTask.new(:feature) do |t|
    t.pattern = FileList['spec{,/features/**}/*_spec.rb']
    t.rspec_opts = ['--color', '--backtrace']
  end
    
  desc "Run all tests except features"
  RSpec::Core::RakeTask.new(:unit) do |t| 
    t.pattern = FileList['spec/**/*_spec.rb'].exclude("spec/features/**/*_spec.rb")
    t.rspec_opts = ['--color', '--backtrace']
  end

  desc "Run a set of tasks to prepare for testing"
  task prep: :environment do
    WebMock.disable!
    Rake::Task["db:migrate"].invoke
    Rake::Task["scholarsphere:fits_conf"].invoke
    Rake::Task["scholarsphere:generate_secret"].invoke
  end  

  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task ci: :environment do
    Rake::Task["scholarsphere:prep"].invoke
    error = test_wrapper('scholarsphere:rspec')
    raise "test failures: #{error}" if error
  end

  namespace :travis do

    desc "Run feature tests on Travis"
    task feature: :environment do
      Rake::Task["scholarsphere:prep"].invoke
      with_test_server do
        Rake::Task["scholarsphere:feature"].invoke
      end
    end

    desc "Run unit tests on Travis"
    task unit: :environment do
      Rake::Task["scholarsphere:prep"].invoke
      with_test_server do
        Rake::Task["scholarsphere:unit"].invoke
      end
    end

    desc 'Run style checker'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.requires << 'rubocop-rspec'
      task.fail_on_error = true
    end 
  end
end
