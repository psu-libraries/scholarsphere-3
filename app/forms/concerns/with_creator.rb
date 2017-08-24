# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  included do
    def creators
      model.creators.build if model.creators.blank?
      model.creators.build # 999 delete this later
      model.creators.to_a
    end

    def self.build_permitted_params
      permitted = super
      permitted << { creators: [:id, :first_name, :last_name, :_destroy] }
      permitted
    end
  end
end
