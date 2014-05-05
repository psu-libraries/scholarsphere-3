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

class DashboardController < ApplicationController
  include  Sufia::DashboardControllerBehavior
  include Hydra::Collections::SelectsCollections
  
  # not filtering further with a specific access level since the catalog controller already gets the colections with edit access
  #  if we include other access levels in this controller we will need to modify this.
  before_filter :find_collections, :only=>:index

  # TODO: This can be removed after we upgrade to hydra-collections 2.0.1 or greater
  def add_collection_filter(solr_parameters, user_parameters)
    super(solr_parameters, user_parameters)
    solr_parameters[:rows] = 100
  end

end
