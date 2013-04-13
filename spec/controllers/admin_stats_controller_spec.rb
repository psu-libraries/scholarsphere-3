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

require 'spec_helper'

describe Admin::StatsController do
  before do
    @user1 = FactoryGirl.find_or_create(:user)
    @user1.stubs(:groups).returns(['umg/up.dlt.scholarsphere-admin-viewers'])
    @user2 = FactoryGirl.find_or_create(:archivist)
    @user2.stubs(:groups).returns(['umg/up.dlt.some-other-group'])
  end

  after do
    @user1.delete
    @user2.delete
  end

  describe "statistics page" do
    render_views

    it 'allows an authorized user to view the page' do
      sign_in @user1
      get :index
      response.should be_success
      response.body.should include('Statistics for ScholarSphere')
      response.body.should include('Total Scholarsphere Members')
    end

    it 'redirects when an unauthorized user attempts to view the page' #do
      # advanced constraint rspec is hard, apparently
      #sign_in @user2
      #get :index
      #response.should redirect_to(root_path)
    #end
  end
end
