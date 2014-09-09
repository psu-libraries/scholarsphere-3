class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  def index
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject &:deleted_file?
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
    super
  end

  protected

  def gather_dashboard_information
    @user = current_user
    @activity = current_user.get_all_user_activity(params[:since].blank? ? DateTime.now.to_i - 24*60*60 : params[:since].to_i)
    @notifications = current_user.mailbox.inbox
  end

end