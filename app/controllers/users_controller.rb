class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior

  before_filter :get_linkedin_url, only: :show

  def get_linkedin_url
    @linkedInUrl = @user.linkedin_handle
    @linkedInUrl = "http://www.linkedin.com/in/" + @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'linkedin.com'
    @linkedInUrl = "http://"+ @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'http'
  end

  protected

  def base_query
    ["ldap_available = ? AND login not in ('testapp','tstem31')", true]
  end

end
