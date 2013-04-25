class Ability
  include Hydra::Ability

  def custom_permissions
    can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending' # cancel
  end

end


