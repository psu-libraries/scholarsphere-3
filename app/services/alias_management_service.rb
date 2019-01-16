# frozen_string_literal: true

class AliasManagementService
  class Error < StandardError
  end

  # @param [Hash, ActionController::Parameters, Alias] attributes_or_alias
  # @return [Alias]
  # Returns an alias for a agent, creating any objects as needed.
  def self.call(parameter)
    if parameter.is_a?(Alias)
      new(alias: parameter)._alias_
    else
      new(parameter.with_indifferent_access)._alias_
    end
  end

  attr_reader :given_name, :display_name, :sur_name, :agent_alias, :agent_attributes

  def initialize(attributes)
    @display_name = attributes.delete(:display_name)
    @agent_alias = attributes.delete(:alias) || find_alias(attributes.delete(:id))
    @agent_attributes = attributes
    @sur_name = attributes.fetch(:sur_name, nil)
    @given_name = attributes.fetch(:given_name, nil)
    if @sur_name.blank? && @given_name.blank? && @display_name.present?
      @sur_name = @display_name
      @agent_attributes[:sur_name] = @sur_name
    end
  end

  def _alias_
    if agent_alias.present?
      raise Error, I18n.t('scholarsphere.aliases.agent_error') if agent_alias.agent.blank?

      agent_alias
    else
      create_alias
    end
  end

  private

    def find_alias(id)
      if id.blank?
        Alias.where(display_name_ssim: display_name).first
      else
        Alias.find(id)
      end
    end

    def create_alias
      raise Error, I18n.t('scholarsphere.aliases.parameter_error') unless all_names_present?

      Alias.create(display_name: display_name, agent: agent)
    end

    def all_names_present?
      display_name.present? && sur_name.present?
    end

    def agent
      agent = Agent.where(sur_name_ssim: sur_name, given_name_ssim: given_name).first
      return agent if agent.present?

      Agent.create(agent_attributes)
    end
end
