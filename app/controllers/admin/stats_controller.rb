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

class Admin::StatsController < ApplicationController
  def index
    @users_count = User.count

    # The 5 most recent users to join
    @users_stats = params.fetch(:users_stats, {})
    if @users_stats[:start_date]
      #@user_stats[:start_date] ||= 7.days.ago
      @recent_users = User.where('created_at >= ?',  @users_stats[:start_date])
    else
      @recent_users = User.order('created_at DESC').limit(5).select('display_name, login, created_at, department')
    end

    # Query Solr for top 5 depositors
    depositor_key = Solrizer.solr_name('depositor', :stored_searchable, type: :string)
    top_depositors_url = "#{ActiveFedora.solr_config[:url]}/terms?terms.fl=#{depositor_key}&terms.sort=count&terms.limit=5&wt=json&omitHeader=true"
    # Parse JSON response (looks like {"terms":{"depositor_tesim":["mjg36",3]}})
    depositors_json = open(top_depositors_url).read
    depositor_tuples = JSON.parse(depositors_json)['terms'][depositor_key] rescue []
    # Change to hash where keys = logins and values = counts
    @active_users = Hash[*depositor_tuples]

    # Query Solr for totals by visibility (read_access_group)
    visibility_key = Solrizer.solr_name('read_access_group', :symbol)
    visibility_url = "#{ActiveFedora.solr_config[:url]}/terms?terms.fl=#{visibility_key}&terms.sort=index&terms.limit=-1&wt=json&omitHeader=true"
    visibility_json = open(visibility_url).read
    visibility_tuples = JSON.parse(visibility_json)['terms'][visibility_key] rescue []
    # Change to hash where keys = logins and values = counts
    visibility_hash = Hash[*visibility_tuples]
    # Drop all groups except for registered (Penn State) and public (Open Access)
    visibility_hash.select! { |k, v| ['registered', 'public'].include? k }

    # Count of documents by permissions
    ActiveFedora::SolrService.instance.conn.commit("expungeDeletes"=>true)
    @files_count = {}
    @files_count[:total] = GenericFile.count
    @files_count[:psu] = visibility_hash['registered'].to_i
    @files_count[:public] = visibility_hash['public'].to_i
    @files_count[:private] = @files_count[:total] - (@files_count[:psu] + @files_count[:public])

    # Query Solr for top 5 depositors
    format_key = Solrizer.solr_name('file_format', Solrizer::Descriptor.new(:string, :indexed, :multivalued))
    top_formats_url = "#{ActiveFedora.solr_config[:url]}/terms?terms.fl=#{format_key}&terms.sort=count&terms.limit=5&wt=json&omitHeader=true"
    formats_json = open(top_formats_url).read
    format_tuples = JSON.parse(formats_json)['terms'][format_key] rescue []
    # Change to hash where keys = logins and values = counts
    @top_formats = Hash[*format_tuples]

    render 'index'
  end
end
