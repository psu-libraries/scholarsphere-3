# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  def creators
    model.creators.build(current_creator_attributes) if model.creators.blank?
    model.creators.to_a
  end

  included do
    # Auto-fill the creator field with the currently logged-in user's name.
    def current_creator_attributes
      return @current_creator_attributes if @current_creator_attributes
      parsed_name = Namae::Name.parse(current_ability.current_user.display_name)
      @current_creator_attributes = {
        given_name: parsed_name.given,
        sur_name: parsed_name.family
      }
    end

    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :given_name, :sur_name, :_destroy] }
      permitted
    end
  end
end
