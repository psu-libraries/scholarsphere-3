# frozen_string_literal: true
# Load the rails application
require File.expand_path('../application', __FILE__)

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      # Re-establish redis connection
      require 'redis'
      config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access

      # The important two lines
      $redis.client.disconnect if $redis
      $redis = begin
                 Redis.new(host: config[:host], port: config[:port], thread_safe: true)
               rescue
                 nil
               end
      Resque.redis.client.reconnect if Resque.redis
    end
  end
else
  config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
  $redis = begin
             Redis.new(host: config[:host], port: config[:port], thread_safe: true)
           rescue
             nil
           end
end

class Logger
  def format_message(_severity, timestamp, _progname, msg)
    "#{timestamp} (#{$PROCESS_ID}) #{msg}\n"
  end
end

# Initialize the rails application
ScholarSphere::Application.initialize!
ActiveRecord::Base.connection.execute("SET AUTOCOMMIT=1") if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) && (ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::Mysql2Adapter)
