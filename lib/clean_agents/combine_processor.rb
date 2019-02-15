# frozen_string_literal: true

module CleanAgents
  class CombineProcessor
    class << self
      def process_combine_groups(combine_groups)
        combine_groups.each_key do |key|
          agent = Agent.find(key)
          other_agents = combine_groups[key].map { |id| Agent.find(id) }
          combine_agents(agent: agent, other_agents: other_agents)
        end
      end

      def combine_agents(agent:, other_agents:)
        other_agents.each do |other_agent|
          other_agent.aliases.each do |agent_alias|
            agent_alias.agent = agent
            agent_alias.save
          end
          other_agent.reload.destroy
        end
        agent.save
      end

      def find_combine_groups(data)
        combines = data.reject { |row| row['Id_of_equal_agent'].blank? }
        combine_groups = combine_group_parents(combine_rows: combines)
        combine_group_children(combine_rows: combines, combine_groups: combine_groups)
      end

      private

        def combine_group_parents(combine_rows:)
          combine_groups = {}
          combine_rows.each do |row|
            if row['id'] == row['Id_of_equal_agent']
              combine_groups[row['id']] = []
            end
          end
          combine_groups
        end

        def combine_group_children(combine_rows:, combine_groups:)
          combine_rows.each do |row|
            if row['id'] != row['Id_of_equal_agent']
              if combine_groups[row['Id_of_equal_agent']].nil?
                raise StandardError.new("Combine group without id setup #{row}")
              end

              combine_groups[row['Id_of_equal_agent']] << row['id']
            end
          end
          combine_groups
        end
    end
  end
end
