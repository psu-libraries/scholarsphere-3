# frozen_string_literal: true

class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior

  before_action :linkedin_url, only: :show
  after_action :copy_orcid_id, only: :update

  def linkedin_url
    @linkedin_url ||= format_linkedin_url
  end

  def index
    return super if params[:uq].blank? || request.format.html? # show users in the system if the request if html or there is no query

    # call out to ldap to get more users if we are searching for a user
    @ldap_cache ||= {}

    query_str = params[:uq]
    users = @ldap_cache[query_str]
    if users.blank?
      users = User.query_ldap_by_name_or_id(query_str)
      @ldap_cache[query_str] = users
    end
    respond_to do |format|
      format.json { render json: users.first(20).to_json }
    end
  end

  def copy_orcid_id
    agent = Agent.where(psu_id: @user.login).first
    if @user.orcid.present? && agent.present?
      agent.orcid_id = @user.orcid
      agent.save
    end
  end

  def user_params
    params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle,
                                 :googleplus_handle, :linkedin_handle, :remove_avatar, :orcid, :opt_out_stats_email)
  end

  protected

    def base_query
      ["ldap_available = ? AND login not in ('testapp','tstem31')", true]
    end

    def format_linkedin_url
      handle = @user.linkedin_handle
      handle = 'http://www.linkedin.com/in/' + handle unless handle.blank? || handle.include?('linkedin.com')
      handle = 'http://' + handle unless handle.blank? || handle.include?('http')
      handle
    end
end
