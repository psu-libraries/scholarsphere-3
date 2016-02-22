namespace :scholarsphere do
  if defined?(RSpec)
    # Only load these files in testing environments
    require 'rspec/core/rake_task'
    require 'rubocop/rake_task'

    desc "Run specs"
    RSpec::Core::RakeTask.new(:rspec) do |t|
      t.rspec_opts = ['--color', '--backtrace', '--format Fuubar']
    end

    desc "Run all feature tests"
    RSpec::Core::RakeTask.new(:feature) do |t|
      t.pattern = FileList['spec{,/features/**}/*_spec.rb']
      t.rspec_opts = ['--color', '--backtrace', '--format Fuubar']
    end
      
    desc "Run all tests except features"
    RSpec::Core::RakeTask.new(:unit) do |t| 
      t.pattern = FileList['spec/**/*_spec.rb'].exclude("spec/features/**/*_spec.rb")
      t.rspec_opts = ['--color', '--backtrace', '--format Fuubar']
    end

    desc "Run a set of tasks to prepare for testing"
    task prep: :environment do
      WebMock.disable!
      Rake::Task["jetty:clean"].invoke
      Rake::Task["scholarsphere:jetty:config"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["scholarsphere:fits_conf"].invoke
      Rake::Task["scholarsphere:generate_secret"].invoke
    end  

    desc "Execute Continuous Integration build (docs, tests with coverage)"
    task ci: :environment do
      Rake::Task["scholarsphere:prep"].invoke
      error = jetty_test('scholarsphere:rspec')
      raise "test failures: #{error}" if error
    end
  
    namespace :travis do

      desc "Run feature tests on Travis"
      task feature: :environment do
        Rake::Task["scholarsphere:prep"].invoke
        error = jetty_test('scholarsphere:feature')
        raise "test failures: #{error}" if error
      end

      desc "Run unit tests on Travis"
      task unit: :environment do
        Rake::Task["scholarsphere:prep"].invoke
        error = jetty_test('scholarsphere:unit')
        raise "test failures: #{error}" if error
      end

      desc 'Run style checker'
      RuboCop::RakeTask.new(:rubocop) do |task|
        task.requires << 'rubocop-rspec'
        task.fail_on_error = true
      end 
    end
  end
end

def jetty_test task
  jetty_params = Jettywrapper.load_config.merge({jetty_home: File.expand_path(File.join(Rails.root, 'jetty'))})
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task[task].invoke
  end
  return error
end
