# frozen_string_literal: true

class CreatorForm
  attr_reader :agent_alias

  delegate :id, :display_name, to: :agent_alias

  # @param [Alias]
  def initialize(agent_alias)
    @agent_alias = agent_alias
  end

  def read_only?
    agent_alias.agent.present?
  end

  def sur_name
    if read_only?
      agent_alias.agent.sur_name
    else
      parsed_name.family
    end
  end

  def given_name
    if read_only?
      agent_alias.agent.given_name
    else
      parsed_name.given
    end
  end

  def psu_id
    return unless read_only?

    agent_alias.agent.psu_id
  end

  def email
    return unless read_only?

    agent_alias.agent.email
  end

  def orcid_id
    return unless read_only?

    agent_alias.agent.orcid_id
  end

  private

    def parsed_name
      @parsed_name ||= Namae::Name.parse(display_name)
    end
end
