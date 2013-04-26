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

describe CollectionsController do
  before(:each) { @routes = Hydra::Collections::Engine.routes }
  before do
    controller.stubs(:has_access?).returns(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    User.any_instance.stubs(:groups).returns([])
    controller.stubs(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe '#new' do
    it 'should assign @collection' do
      get :new
      assigns(:collection).should be_kind_of(Collection)
    end
  end
  
  describe '#create' do
    it "should create a Collection" do
      controller.expects(:has_access?).returns(true)
      old_count = Collection.count
      post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
      Collection.count.should == old_count+1
    end
  end
end
