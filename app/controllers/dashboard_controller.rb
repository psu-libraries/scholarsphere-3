class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  def index
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject &:deleted_file?
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
    super
  end

end