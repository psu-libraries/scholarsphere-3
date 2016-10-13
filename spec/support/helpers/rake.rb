# frozen_string_literal: true
module RakeHelper
  def load_rake_environment(files)
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    files.each { |file| load file }
  end

  # @param [String] task the rake task such as my:task
  # @param [Array, String, NilClass] arguments string or array of arguments that get passed to the task.
  #                                  Defaults to nil.
  def run_task(task, arguments = nil)
    capture_stdout do
      @rake[task].invoke(*arguments)
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
