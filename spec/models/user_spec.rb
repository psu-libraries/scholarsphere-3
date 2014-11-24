require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.find_or_create(:jill)
    @another_user = FactoryGirl.find_or_create(:archivist)
  end
  it "should have a login" do
    @user.login.should == "jilluser"
  end
  it "should redefine to_param to make redis keys more recognizable" do
    @user.to_param.should == @user.login
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
end
