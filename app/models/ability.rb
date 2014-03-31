class Ability
  include Hydra::Ability

  def custom_permissions
    can :create, :all if user_groups.include? 'registered'

    can :transfer, String do |pid|
      get_depositor_from_pid(pid) == current_user.user_key
    end
    can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    # a user who sent a proxy deposit request can cancel it if it's pending.
    can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending'
    can :edit, User, id: current_user.id
  end

  private

  def get_depositor_from_pid(pid)
    GenericFile.load_instance_from_solr(pid).depositor
  rescue
    nil
  end

  "\n    can :create, :all if user_groups.include? 'registered'\n"

end
