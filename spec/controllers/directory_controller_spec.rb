require 'spec_helper'

describe DirectoryController do
  routes { Sufia::Engine.routes }
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @another_user = FactoryGirl.find_or_create(:archivist)
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
