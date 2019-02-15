# frozen_string_literal: true

module CleanAgents
  class Processor
    class << self
      def parse_file(file_name)
        file = File.new(file_name, encoding: 'bom|utf-8')
        lines = file.read
        parse_csv(lines)
      end

      def parse_csv(csv)
        data = CSV.parse(csv, headers: true, encoding: 'bom|utf-8')
        { split_groups: CleanAgents::SplitProcessor.find_split_groups(data),
          combine_groups: CleanAgents::CombineProcessor.find_combine_groups(data),
          file_data: data }
      end

      def process_data(parsed_info)
        CleanAgents::SplitProcessor.process_split_groups(parsed_info[:split_groups])
        CleanAgents::CombineProcessor.process_combine_groups(parsed_info[:combine_groups])
        process_name_changes(parsed_info[:file_data])
      end

      def split_agent(agent:, names:)
        CleanAgents::SplitProcessor.split_agent(agent: agent, names: names)
      end

      def combine_agents(agent:, other_agents:)
        CleanAgents::CombineProcessor.combine_agents(agent: agent, other_agents: other_agents)
      end

      private

        def process_name_changes(file_data)
          file_data.each do |row|
            next if row['revised_sur_name'].blank? || !Agent.exists?(row['id'])

            update_agent_data(row)
          end
        end

        def update_agent_data(row)
          agent = Agent.find(row['id'])
          agent.sur_name = row['revised_sur_name']
          agent.given_name = row['revised_given_name']
          agent.email = row['revised_email'] if row['revised_email'].present?
          agent.save
        end
    end
  end
end
