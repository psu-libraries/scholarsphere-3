# frozen_string_literal: true
class BaseAbility
  include Hydra::Ability
  include CurationConcerns::Ability
  include Sufia::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]

  def editor_abilities
    can :read, ContentBlock
  end
end
