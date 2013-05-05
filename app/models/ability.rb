class Ability
  include Hydra::Ability

  def custom_permissions
    can :transfer, String do |pid|
      get_depositor_from_pid(pid) == current_user.user_key
    end
    can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
    can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending' # cancel
  end

  private

  def get_depositor_from_pid(pid)
    GenericFile.load_instance_from_solr(pid).depositor
  rescue
    nil
  end
end
