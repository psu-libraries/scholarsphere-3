module RakeHelper
  def load_rake_environment(files)
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    files.each { |file| load file }
  end

  def run_task(task)
    capture_stdout do
      @rake[task].invoke
    end
  end

  # saves original $stdout in variable
  # set $stdout as local instance of StringIO
  # yields to code execution
  # returns the local instance of StringIO
  # resets $stdout to original value
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end

  RSpec.configure do |config|
    config.include RakeHelper
  end
end
