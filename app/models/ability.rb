# frozen_string_literal: true
class Ability < BaseAbility
  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if current_user.administrator?
  end

  def editor_abilities
    super
    if current_user.administrator?
      can :create, TinymceAsset
      can [:create, :update], ContentBlock
      can [:edit, :update], GenericFile
    end
  end

  def stats_abilities
    super
    can :admin_stats, User if current_user.administrator?
  end
end
