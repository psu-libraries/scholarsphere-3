# frozen_string_literal: true

module WithCreator
  extend ActiveSupport::Concern

  included do
    def initialize_field(key)
      if key == :creator
        self[key] = creator
      else
        super
      end
    end

    def creator
      @creator ||= [Namae::Name.parse(current_ability.current_user.name).sort_order]
      @creator
    end
  end
end
