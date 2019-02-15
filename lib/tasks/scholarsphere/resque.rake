# frozen_string_literal: true

namespace :scholarsphere do
  namespace :resque do
    desc 'Index a single object in solr'
    task count: :environment do
      output_file = File.new(Rails.root.join('/tmp/resque_admin_queue_failure_count.txt'), 'w+')
      output_file.puts Resque::Failure.count
      output_file.close
    end
  end
end
