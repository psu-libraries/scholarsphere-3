# -*- coding: utf-8 -*-
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

# -*- encoding : utf-8 -*-

require 'blacklight/catalog'
require 'blacklight_advanced_search'
# bl_advanced_search 1.2.4 is doing unitialized constant on these because we're calling ParseBasicQ directly
require 'parslet'
require 'parsing_nesting/tree'


class StatsController < ApplicationController 

  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Controller::ControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ

  def list 

    if user_logged_in?
       if current_user.groups.include?('umg/up.dlt.applicationsteam')
       
##       if current_user.groups.include?('umg/up.dlt.scholarsphere-admin-viewers')

###       listing of all users with valid display name (eliminates audituser)
          all_users=User.where("display_name != ''")

          @object_count = GenericFile.count
          @user_count = all_users.count

###       Get the 3 most recent users to join
          @users_list = all_users.where("display_name != ''").order('created_at DESC').limit(5)

####      Get the 5 most active users
          @gfl=GenericFile.all.group_by {|d|d.depositor}.sort_by {|k,v|v.count}.reverse
          @gf=@gfl[0..4]
   
####  Get count of documents by permissions
          @private=0
          @public=0
          @psu=0
          GenericFile.all.each do |gf|
             if gf.permissions.map { |perm| perm[:access] if perm[:name] == "public" }.compact.first
                @public+=1
             elsif
                gf.permissions.map { |perm| perm[:access] if perm[:name] == "registered"}.compact.first
                   @psu+=1
                else
                   @private+=1
             end
          end

##        Get top 5 object formats 
          @ffl=GenericFile.all.group_by {|f|f.format_label}.sort_by {|k,v|v.count}.reverse
          @ff=@ffl[0..4]

          render "list"
       else
          render :template => '/error/404', :layout => "error", :formats => [:html], :status => 404
       end
    else
       flash[:now] = 'OOOPS, login please'
    end
  end
end
