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
    if @user.respond_to? :profile_events
      @events = @user.profile_events(100)
    else
      @events = []
    end

    num_retry = 0
    begin
      problem_index = 0
      num_retry += 1
      @trophies = []
      @user.trophies.each do |t|
        problem_index += 1
        @trophies << GenericFile.find("scholarsphere:#{t.generic_file_id}")
      end
      rescue ActiveFedora::ObjectNotFoundError => e
        loop_counter = 0
        @user.trophies.each do |t|
          loop_counter += 1
          if problem_index == loop_counter
             t.delete
          end
        end
        if num_retry <= 5
          retry
        else
          raise
        end
    end
    @followers = @user.followers
    @following = @user.all_following
    @linkedInUrl = @user.linkedin_handle
    @linkedInUrl = "http://www.linkedin.com/in/" + @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'linkedin.com'
    @linkedInUrl = "http://"+ @linkedInUrl unless @linkedInUrl.blank? or @linkedInUrl.include? 'http'
  end

  # Display form for users to edit their profile information
  def edit
    @user = current_user
    @groups = @user.groups
    @trophies = []

    num_retry = 0
    begin
      problem_index = 0
      num_retry += 1
      @trophies = []
      @user.trophies.each do |t|
        problem_index += 1
        @trophies << GenericFile.find("scholarsphere:#{t.generic_file_id}")
      end
      rescue ActiveFedora::ObjectNotFoundError => e
        loop_counter = 0
        @user.trophies.each do |t|
          loop_counter += 1
          if problem_index == loop_counter
             t.delete
          end
        end
        if num_retry <= 5
          retry
        else
          raise
        end
    end
  end

  protected 

  def base_query
    ["ldap_available = ? AND login not in ('testapp','tstem31')", true]
  end

end
