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

describe RoleMapper do
  before do
    @user = FactoryGirl.find_or_create(:user)
    User.any_instance.stub(:groups).and_return(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
  end
  after do
    @user.delete
  end
  subject {::RoleMapper.roles(@user.login)}
  it { should == ["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"]}
end

