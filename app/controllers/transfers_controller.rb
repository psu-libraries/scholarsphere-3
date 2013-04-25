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

  def new
    pid = Sufia::Noid.namespaceize(params[:generic_file_id])
    authorize! :edit, pid
    @generic_file = GenericFile.new(pid: pid)
    @proxy_deposit_request.pid = pid
  end

  def create
    pid = Sufia::Noid.namespaceize(params[:generic_file_id])
    authorize! :edit, pid
    @proxy_deposit_request.sending_user = current_user
    @proxy_deposit_request.pid = pid 
    if @proxy_deposit_request.save
      redirect_to transfers_path, notice: "Transfer request created"
    else
      render "new"
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
