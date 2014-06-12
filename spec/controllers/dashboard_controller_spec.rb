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

describe DashboardController do
  routes { Sufia::Engine.routes }
  before do
    User.any_instance.stub(:groups).and_return([])
  end
  # This doesn't really belong here, but it works for now
  describe "authenticate!" do
    before(:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      request.stub(:headers).and_return('REMOTE_USER' => @user.login)
      @strategy = Devise::Strategies::HttpHeaderAuthenticatable.new(nil)
      @strategy.stub(request: request)
    end
    after(:each) do
      @user.delete
    end
    it "should populate LDAP attrs if user is new" do
      User.stub(:find_by_login).with(@user.login).and_return(nil)
      User.should_receive(:create).with(login: @user.login, email:@user.login).once.and_return(@user)
      User.any_instance.should_receive(:populate_attributes).once
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in @user
      get :index
    end
    it "should not populate LDAP attrs if user is not new" do
      User.stub(:find_by_login).with(@user.login).and_return(@user)
      User.should_receive(:create).with(login: @user.login).never
      User.any_instance.should_receive(:populate_attributes).never
      @strategy.should be_valid
      @strategy.authenticate!.should == :success
      sign_in @user
      get :index
    end
  end
  describe "logged in user" do
    before (:each) do
      @user = FactoryGirl.find_or_create(:archivist)
      sign_in @user
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#index" do
      before (:each) do
        xhr :get, :index
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('dashboard/index')
      end
      it "should return a list of transfers" do
        expect(assigns(:incoming)).to eq(ProxyDepositRequest.where(receiving_user_id: @user.id).reject &:deleted_file?)
        expect(assigns(:outgoing)).to eq(ProxyDepositRequest.where(sending_user_id: @user.id))
      end
    end
  end
  describe "not logged in as a user" do
    describe "#index" do
      it "should return an error" do
        xhr :post, :index
        response.should_not be_success
      end
    end
  end
end
