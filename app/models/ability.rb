# frozen_string_literal: true
class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  include Sufia::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if admin?
  end

  def editor_abilities
    super
    if admin?
      can :create, TinymceAsset
      can [:create, :update], ContentBlock
    end
    can :read, ContentBlock
  end

  def stats_abilities
    super
    can :admin_stats, User if admin?
  end

  # TODO: Remove this once projecthydra-labs/curation_concerns#724 is approved
  def admin?
    current_user.administrator?
  end
end
