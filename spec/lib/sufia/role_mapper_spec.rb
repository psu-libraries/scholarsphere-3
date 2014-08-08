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

