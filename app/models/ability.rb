class Ability
  include Hydra::Ability
  include Sufia::Ability

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if user_groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
  end

  def editor_abilities
    if user_groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
      can :create, TinymceAsset
      can :update, ContentBlock
    end
  end
end
