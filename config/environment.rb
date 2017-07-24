# frozen_string_literal: true
# Load the rails application
require File.expand_path('../application', __FILE__)

class Logger
  def format_message(_severity, timestamp, _progname, msg)
    "#{timestamp} (#{$PROCESS_ID}) #{msg}\n"
  end
end

# Initialize the rails application
ScholarSphere::Application.initialize!
ActiveRecord::Base.connection.execute('SET AUTOCOMMIT=1') if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter) && (ActiveRecord::Base.connection.instance_of? ActiveRecord::ConnectionAdapters::Mysql2Adapter)
