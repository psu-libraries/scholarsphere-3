# frozen_string_literal: true
class BaseAbility
  include Hydra::Ability
  include Sufia::Ability

  def editor_abilities
    can :read, ContentBlock
  end
end
