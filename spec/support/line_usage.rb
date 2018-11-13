# frozen_string_literal: true

# @note Prints to a log, and optionally STDOUT, when a particular line is hit during a test.
#
# @example To register a line, add:
#   LineUsage.register(name: self, caller: __method__)
#
# @exmaple To write STDOUT as well as the log:
#   LineUsage.register(name: self, caller: __method__, write_out: true)
class LineUsage
  cattr_accessor :current_test

  class << self
    def register(name:, caller:, write_out: false)
      usage_log.info("#{current_test} #{name.class}##{caller}")
      puts "#{current_test} #{name.class}##{caller}" if write_out
    end

    private

      def usage_log
        @usage_log ||= Logger.new(File.open(Rails.root.join('log', 'line_usage.log'), 'w'))
      end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rm_rf(Rails.root.join('log', 'line_usage.log'))
  end

  config.before do
    LineUsage.current_test = self.class.to_s
  end
end
