# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior

  # Display user profile
  def show
    @events = @user.profile_events(100) rescue []
    @followers = @user.followers
    @following = @user.all_following
    @linkedInUrl = @user.linkedin_handle
    @linkedInUrl = "http://www.linkedin.com/in/" + @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'linkedin.com'
    @linkedInUrl = "http://"+ @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'http'
    adjust_trophies!
  end

  # Display form for users to edit their profile information
  def edit
    @user = current_user
    @groups = @user.groups
    @trophies = []
    adjust_trophies!
  end


  def index
    sort_val = get_sort
    query = params[:uq].blank? ? nil : "%"+params[:uq].downcase+"%"
    base = User.where(*base_query)
    unless query.blank?
      base = base.where("#{Devise.authentication_keys.first} like lower(?) OR lower( display_name) like lower(?)", query, query)
    end
    @users = base.order(sort_val).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.json { render json: @users.to_json }
    end

  end
    protected

  def adjust_trophies!
    @user.trophies.reject!  do  |t|
      begin
        GenericFile.find(Sufia::Noid.namespaceize(t.generic_file_id))
        false
      rescue ActiveFedora::ObjectNotFoundError
        t.destroy
        true
      end
    end
    @user.reload
    @trophies = @user.trophy_files
  end

  def base_query
    ["ldap_available = ? AND login not in ('testapp','tstem31')", true]
  end
end
