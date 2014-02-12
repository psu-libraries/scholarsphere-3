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

describe User do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
    @another_user = FactoryGirl.find_or_create(:archivist)
  end
  after(:all) do
    @user.delete
    @another_user.delete
  end
  it "should have a login" do
    @user.login.should == "jilluser"
  end
  it "should have activity stream-related methods defined" do
    @user.should respond_to(:stream)
    @user.should respond_to(:events)
    @user.should respond_to(:profile_events)
    @user.should respond_to(:create_event)
    @user.should respond_to(:log_event)
    @user.should respond_to(:log_profile_event)
  end
  it "should have social attributes" do
    @user.should respond_to(:twitter_handle)
    @user.should respond_to(:facebook_handle)
    @user.should respond_to(:googleplus_handle)
  end
  it "should redefine to_param to make redis keys more recognizable" do
    @user.to_param.should == @user.login
  end
  it "should have a cancan ability defined" do
    @user.should respond_to(:can?)
  end
  it "should not have any followers" do
    @user.followers_count.should == 0
    @another_user.follow_count.should == 0
  end
  describe "follow/unfollow" do
    before(:all) do
      @user = FactoryGirl.find_or_create(:user)
      @another_user = FactoryGirl.find_or_create(:archivist)
      @user.follow(@another_user)
    end
    after do
      @user.delete
      @another_user.delete
    end
    it "should be able to follow another user" do
      @user.following?(@another_user).should be_true
      @another_user.following?(@user).should be_false
      @another_user.followed_by?(@user).should be_true
      @user.followed_by?(@another_user).should be_false
    end
    it "should be able to unfollow another user" do
      @user.stop_following(@another_user)
      @user.following?(@another_user).should be_false
      @another_user.followed_by?(@user).should be_false
    end
  end
  describe "#groups" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', @user.login)
        Hydra::LDAP.should_receive(:groups_for_user).with(filter).and_return(["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"])
        Hydra::LDAP.connection.stub(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
      end
      it "should return a list" do
        @user.groups.should == ["umg/up.dlt.gamma-ci", "umg/up.dlt.redmine"]
      end
    end
    describe "empty user" do
      before do
        Hydra::LDAP.should_receive(:groups_for_user).never
        Hydra::LDAP.connection.should_receive(:get_operation_result).never
      end
      it "should return a list" do
        u = User.new
        u.groups.should == []
      end
    end
  end
  describe "#ldap_exist?" do
    describe "valid user" do
      before do
        filter = Net::LDAP::Filter.eq('uid', @user.login)
        Hydra::LDAP.should_receive(:does_user_exist?).with(filter).and_return(true)
        Hydra::LDAP.connection.stub(:get_operation_result).and_return(OpenStruct.new({code:0, message:"Success"}))
      end
      it "should return a list" do
        @user.ldap_exist?.should == true
      end
    end
    describe "empty user" do
      before do
        Hydra::LDAP.should_receive(:does_user_exist?).never
        Hydra::LDAP.connection.should_receive(:get_operation_result).never
      end
      it "should return a list" do
        u = User.new
        u.ldap_exist?.should == false
      end
    end
  end

  describe "#directory_attributes" do
    before do
      entry = Net::LDAP::Entry.new()
      entry['dn'] = ["uid=mjg36,dc=psu,edu"]
      entry['cn'] = ["MICHAEL JOSEPH GIARLO"]
      Hydra::LDAP.should_receive(:get_user).and_return([entry])
    end
    it "should return user attributes from LDAP" do
      User.directory_attributes('mjg36', ['cn']).first['cn'].should == ['MICHAEL JOSEPH GIARLO']
    end
  end

  describe "proxy_deposit_rights" do
    before do
      @u1 = FactoryGirl.create :random_user
      @u2 = FactoryGirl.create :random_user
      subject.can_receive_deposits_from << @u1
      subject.can_make_deposits_for << @u2
      subject.save!
    end
    it "can_receive_deposits_from" do
      subject.can_receive_deposits_from.should == [@u1]
      @u1.can_make_deposits_for.should == [subject]
    end
    it "can_make_deposits_for" do
      subject.can_make_deposits_for.should == [@u2]
      @u2.can_receive_deposits_from.should == [subject]
    end
  end
end
