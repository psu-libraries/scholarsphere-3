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
      @current_creator_attributes ||= { display_name: current_ability.current_user.display_name }
    end

    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :display_name, :given_name, :sur_name, :_destroy] }
      permitted
    end
  end
end
