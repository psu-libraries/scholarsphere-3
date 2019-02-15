# frozen_string_literal: true

module CleanAgents
  #
  # This class is responsible for looking through the csv file and finding agents that need to be split
  #
  # They come in the format (line 1 - id and first person, line 2 - no id and second name)
  #
  # id,psu_id_ssim,sur_name_ssim,given_name_ssim,email_ssim,Id_of_equal_agent,id_split_from_agent,revised_sur_name,revised_given_name,revised_email
  # 05b3c71d-d98f-4755-8c1b-a5ef64593625,,"Fisher\, Chuck : Hsing\, Pen-Yuan",,,,05b3c71d-d98f-4755-8c1b-a5ef64593625,Hsing,Pen-Yuan,
  # ,,,,,,05b3c71d-d98f-4755-8c1b-a5ef64593625,Fisher,Chuck,
  class SplitProcessor
    class << self
      def process_split_groups(split_groups)
        split_groups.each do |group|
          agent = Agent.find(group[:id])
          split_agent(agent: agent, names: group[:names])
        end
      end

      def find_split_groups(data)
        splits = data.reject { |row| row['id_split_from_agent'].blank? }
        split_group_rows(split_rows: splits)
      end

      def split_agent(agent:, names:)
        additional_agents_needed = names.count - 1
        agent.update(names.first)
        updated_agents = [agent]
        1.upto(additional_agents_needed) do |count|
          updated_agents << create_agent_and_alias(names[count])
        end
        agent.aliases.each do |agent_alias|
          update_creators(agent_alias, agent.display_name, updated_agents)
        end
        updated_agents
      end

      private

        def split_group_rows(split_rows:)
          split_groups = []
          current_agent = nil
          split_rows.each do |row|
            if current_agent && row['id'].present?
              split_groups << current_agent
            end
            current_agent = update_current_agent(row: row, current_agent: current_agent)
          end
          split_groups << current_agent
          split_groups
        end

        def create_agent_and_alias(name_hash)
          new_agent = Agent.new(name_hash)
          Alias.create(display_name: new_agent.display_name, agent: new_agent)
          new_agent.save
          new_agent
        end

        def update_creators(agent_alias, display_name, updated_agents)
          agent_alias.display_name = display_name
          agent_alias.save
          objects = ActiveFedora::Base.where(creator_list_ssim: agent_alias.id)
          objects.each do |object|
            object.creators = [updated_agents.map(&:aliases)].flatten
            object.save
          end
        end

        def update_current_agent(row:, current_agent:)
          if row['id'].present?
            current_agent = { id: row['id'], names: [{ sur_name: row['revised_sur_name'], given_name: row['revised_given_name'], email: row['revised_email'] }] }
          else
            raise StandardError.new("bad csv file: Agent out of order: #{row}") if current_agent.nil? || current_agent[:id] != row['id_split_from_agent']

            current_agent[:names] << { sur_name: row['revised_sur_name'], given_name: row['revised_given_name'], email: row['revised_email'] }
          end
          current_agent
        end
    end
  end
end
