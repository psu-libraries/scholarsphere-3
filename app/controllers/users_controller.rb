class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior

  before_filter :get_linkedin_url, only: :show

  def get_linkedin_url
    @linkedInUrl = @user.linkedin_handle
    @linkedInUrl = "http://www.linkedin.com/in/" + @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'linkedin.com'
    @linkedInUrl = "http://"+ @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'http'
  end

  def index
    return super if params[:uq].blank? || request.format.html? # show users in the system if the request if html or there is no query

    # call out to ldap to get more users if we are searching for a user
    @ldap_cache ||= {}

    query_str = params[:uq]
    users = @ldap_cache[query_str]
    if (users.blank?)
       users = User.query_ldap_by_name_or_id(query_str)
       @ldap_cache[query_str] =users
    end
    respond_to do |format|
      format.json { render json: users.first(20).to_json }
    end

  end

  protected

  def base_query
    ["ldap_available = ? AND login not in ('testapp','tstem31')", true]
  end

end
