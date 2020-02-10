# frozen_string_literal: true

namespace :scholarsphere do
  namespace :migration do
    desc 'Migrate a single work'
    task 'work', [:pid] => :environment do |_cmd, args|
      result = Scholarsphere::Migration::ExportService.call(args[:pid])
      pp JSON.parse(result.body)
    end
  end
end
