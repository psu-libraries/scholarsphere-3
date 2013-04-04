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

          @totals=Hash.new

###       listing of all users with valid display name (eliminates audituser)

           @all_users=User.where("login NOT LIKE '%audituser%' AND login NOT LIKE '%batchuser%'")

###       listing of all objects
          @all_objs=GenericFile.all

####  Get count of documents by permissions
          @totals['private']=0
          @totals['public']=0
          @totals['psu']=0          
          @all_objs.each do |gf|
             total_perms(gf.permissions.map { |perm| perm[:name] }.compact.first
)
          end


###       Get the 5  most recent users to join

          @recent_users = @all_users.where("created_at != ''").select('display_name, login, created_at').order('created_at DESC').limit(5)


####      Get the 5 most active users
          @active_users=@all_objs.group_by{|d|d.depositor}.sort_by{|k,v|v.count}.reverse.take(5).map{ |k,v| k={'login'=>k, 'count'=>v.count}}


##        Get top 5 object formats
          @formats=@all_objs.group_by{|f|f.format_label}.sort_by{|k,v|v.count}.reverse.take(5).map{|k,v| k={'format'=>k, 'count'=>v.count} }

          render "list"
  end

  def total_perms(pm)
    if  pm == "public" 
       @totals['public']+=1
    elsif pm == "registered"
       @totals['psu']+=1
    else
       @totals['private']+=1
    end
  end

end
