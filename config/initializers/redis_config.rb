# frozen_string_literal: true
require 'redis'
config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    next unless forked
    # Re-establish redis connection
    Redis.current.disconnect!
    Redis.current = Redis.new(config.merge(thread_safe: true))
  end
else
  Redis.current = Redis.new(config.merge(thread_safe: true))
end
