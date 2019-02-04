# frozen_string_literal: true

class CreatorForm
  attr_reader :agent_alias

  delegate :id, :display_name, to: :agent_alias
  delegate :sur_name, :given_name, :psu_id, :email, :orcid_id, to: :@agent

  # @param [Alias]
  def initialize(agent_alias)
    @agent_alias = agent_alias
    @agent_alias.agent = Agent.new(sur_name: parsed_name.family, given_name: parsed_name.given) if @agent_alias.agent.blank?
    @agent = @agent_alias.agent
  end

  def read_only?
    agent_alias.agent.present? && agent_alias.agent.id.present?
  end

  private

    def parsed_name
      @parsed_name ||= Namae::Name.parse(display_name)
    end
end
