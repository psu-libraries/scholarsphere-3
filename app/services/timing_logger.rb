# frozen_string_literal: true

class TimingLogger
  attr_accessor :log_instance

  def initialize(logdev = Rails.root.join('log', 'timing.log'), shift_age = 7, shift_size = 1048576)
    @log_instance = Logger.new(logdev, shift_age, shift_size) if enabled?
  end

  def log(action:, start_time:)
    return unless enabled?
    end_time = Time.now.to_f
    log_instance.info("#{action} #{end_time - start_time.to_f}")
  end

  private

    def enabled?
      @enabled ||= ENV.fetch('timing_enabled', 'false').casecmp('true').zero?
    end
end
