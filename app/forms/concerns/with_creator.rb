# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  # @return [Array<CreatorForm>]
  # If there are no creators, a new CreatorForm is built using the logged-in user
  def creators
    if model.creators.empty?
      [CreatorForm.new(Alias.new(display_name: current_display_name, agent: current_agent))]
    else
      model.creators.map { |c| CreatorForm.new(c) }
    end
  end

  included do
    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :display_name, :given_name, :sur_name, :psu_id, :email, :orcid_id, :_destroy] }
      permitted
    end
  end

  private

    # @return [String]
    def current_display_name
      current_user.display_name
    end

    # @return [User]
    # Sometimes current_ability is really a user
    # @todo See https://github.com/psu-stewardship/scholarsphere/issues/1038
    def current_user
      if current_ability.is_a?(User)
        current_ability
      else
        current_ability.current_user
      end
    end

    # @return [Agent]
    # Finds the existing agent for the current user or builds an agent if it doesn't exist
    def current_agent
      Agent.where(psu_id: current_user.login).first || create_agent
    end

    def create_agent
      parsed_name = Namae::Name.parse(current_user.display_name)
      Agent.new(psu_id: current_user.login, email: current_user.email, sur_name: parsed_name.family,
                given_name: parsed_name.given, orcid_id: current_user.orcid)
    end
end
