class Ability
  include Hydra::Ability
  include Sufia::Ability

  def custom_permissions
    can :transfer, String do |pid|
      get_depositor_from_pid(pid) == current_user.user_key
    end
    can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    # a user who sent a proxy deposit request can cancel it if it's pending.
    can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending'
    can :edit, User, id: current_user.id
  end

  def featured_work_abilities
    can [:create, :destroy, :update], FeaturedWork if user_groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
  end

  def generic_file_abilities
    can :create, GenericFile if user_groups.include? 'registered'
    can :create, Collection if user_groups.include? 'registered'
    can :create, ProxyDepositRequest if user_groups.include? 'registered'
  end

  def editor_abilities
    Rails.logger.warn "#### \n \n Groups #{user_groups} \n\n"
    if user_groups.include? 'umg/up.dlt.scholarsphere-admin-viewers'
      Rails.logger.warn "\n\ngot to editor abilities\n\n"
      can :create, TinymceAsset
      can :update, ContentBlock
    end
  end

  def stats_abilities
    alias_action :stats, to: :read
  end

  private

  def get_depositor_from_pid(pid)
    GenericFile.load_instance_from_solr(pid).depositor
  rescue
    nil
  end

  "\n    can :create, :all if user_groups.include? 'registered'\n"

end
