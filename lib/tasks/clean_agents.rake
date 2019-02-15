# frozen_string_literal: true

require 'clean_agents/processor'

namespace :scholarsphere do
  namespace :clean_agents do
    # adding a logger since it got removed from our gemset
    def logger
      Rails.logger
    end

    desc 'clean agents'
    task 'clean_agents' => :environment do
      parsed_info = CleanAgents::Processor.parse_file(Rails.root.join('lib/clean_agents/agents_cleaned.csv'))
      CleanAgents::Processor.process_data(parsed_info)
      parsed_info[:combine_groups].each_key do |key|
        if Agent.find(key).aliases.count < parsed_info[:combine_groups][key].count + 1
          logger.warn "Bad aliases #{key}"
        end
      end
      logger.warn 'all good if nothing printed above'
    end
  end
end
