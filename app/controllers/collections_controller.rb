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

class CollectionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior
  include BlacklightAdvancedSearch::ParseBasicQ
  include BlacklightAdvancedSearch::Controller
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier, :except => [:index, :create, :new]
  before_filter :filter_docs_with_read_access!, :except => [:show]
  before_filter :has_access?, :except => [:show]
  before_filter :initialize_fields_for_edit, only:[:edit, :new]
  CollectionsController.solr_search_params_logic += [:add_access_controls_to_solr_params]

  layout "sufia-one-column"

  def query_collection_members
    flash[:notice]=nil if flash[:notice] == "Select something first"
    query = params[:cq]

    #merge in the user parameters and the attach the collection query
    solr_params =  (params.symbolize_keys).merge({:q => query})

    # run the solr query to find the collections
    (@response, @member_docs) = get_search_results(solr_params)
  end


  def after_destroy (id)
    respond_to do |format|
      format.html { redirect_to sufia.dashboard_index_path, notice: 'Collection was successfully deleted.' }
      format.json { render json: {id:id}, status: :destroyed, location: @collection }
    end
  end
  
  def initialize_fields_for_edit
    @collection.initialize_fields
  end

end
