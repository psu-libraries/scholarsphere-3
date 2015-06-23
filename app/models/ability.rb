class Ability
  include Hydra::Ability
  include Sufia::Ability

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if admin_user?
  end

  def editor_abilities
    if admin_user?
      can :create, TinymceAsset
      can [:create, :update], ContentBlock
    end
    can :read, ContentBlock
  end

  private

    def admin_user?
      user_groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
    end
end
