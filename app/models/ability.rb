class Ability
  include Hydra::Ability

  def custom_permissions
    can :accept, ProxyDepositRequest, receiving_user_id: current_user.id
    can :destroy, ProxyDepositRequest, sending_user_id: current_user.id
  end

end


