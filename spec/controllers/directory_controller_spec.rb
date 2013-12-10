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

describe DirectoryController do
  routes { Sufia::Engine.routes }
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
    @another_user = FactoryGirl.find_or_create(:archivist)
  end
  after(:all) do
    @user.delete
    @another_user.delete
  end
  describe "#user" do
    it "should get an existing user" do
      User.stub(:directory_attributes).and_return('{"attr":"abc"}')
      get :user, uid:@user.id
      response.should be_success
      lambda { JSON.parse(response.body) }.should_not raise_error
      results = JSON.parse(response.body)
      results["attr"].should == "abc"
    end
  end
end
