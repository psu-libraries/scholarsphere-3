class Ability
  include Hydra::Ability

  def custom_permissions
    can :proxy, GenericFile do |file|
      ProxyDepositRequest.where(pid: file.id, fulfillment_date: nil, receiving_user_id: current_user.id).first
    end
  end

end


