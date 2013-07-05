class DepositorsController < ApplicationController

  before_filter :authenticate_user!

  def create
    response = {}
    unless params[:user_id] == params[:grantee_id]
      grantor = User.find_by_user_key(params[:user_id])
      authorize! :edit, grantor
      grantee = User.find_by_user_key(params[:grantee_id])
      unless grantor.can_receive_deposits_from.include? (grantee)
        grantor.can_receive_deposits_from << grantee
        response = {name: grantee.name, delete_path: user_depositor_path(grantor.user_key, grantee.user_key) }
      end
    end
    respond_to do |format|
      format.json { render json: response}
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
