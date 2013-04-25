class TransfersController < ApplicationController
  load_and_authorize_resource :proxy_deposit_request, parent: false, except: :index

  # Catch permission errors
  # TODO we should make this a module in Sufia
  rescue_from CanCan::AccessDenied do |exception|
    if current_user and current_user.persisted?
      redirect_to root_url, :alert => exception.message
    else
      session["user_return_to"] = request.url
      redirect_to new_user_session_url, :alert => exception.message
    end
  end

  def index
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id)
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
  end

  def accept
    @proxy_deposit_request.transfer!
    redirect_to transfers_path, notice: "Transfer complete"
  end

  def reject
    @proxy_deposit_request.reject!
    redirect_to transfers_path, notice: "Transfer rejected"
  end

  def destroy
    @proxy_deposit_request.cancel!
    redirect_to transfers_path, notice: "Transfer canceled"
  end
end
