# frozen_string_literal: true

namespace :scholarsphere do
  desc 'Truncate sreahces table'
  task truncate_searches: :environment do
    settings = Rails.configuration.database_configuration[Rails.env || 'test']
    output_file = File.join(ScholarSphere::Application.config.backup_directory, "#{settings['database']}-#{Time.now.strftime('%Y%m%d-%H:%M')}.sql")

    command = '/usr/bin/env mysqldump'
    command = "#{command} -h #{settings['host']}" if settings['host'].present?
    command = "#{command} -u #{settings['username']} -p#{settings['password']} #{settings['database']} searches > #{output_file}"
    if system(command)
      conn = ActiveRecord::Base.connection
      conn.execute('TRUNCATE searches')
    else
      abort('Error running dump')
    end
  end
end
