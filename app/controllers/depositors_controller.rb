class DepositorsController < ApplicationController

  before_filter :authenticate_user!

  def create
    grantor = User.find_by_user_key(params[:user_id])
    authorize! :edit, grantor
    grantee = User.find_by_user_key(params[:grantee_id])
    grantor.can_receive_deposits_from << grantee
    respond_to do |format|
      format.json { render json: {name: grantee.name, delete_path: user_depositor_path(grantor.user_key, grantee.user_key) }}
    end
  end

  def destroy
    grantor = User.find_by_user_key(params[:user_id])
    authorize! :edit, grantor
    grantor.can_receive_deposits_from.delete(User.find_by_user_key(params[:id]))
    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
