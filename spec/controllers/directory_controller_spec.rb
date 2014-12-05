require 'spec_helper'

describe DirectoryController, :type => :controller do
  routes { Sufia::Engine.routes }
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @another_user = FactoryGirl.find_or_create(:archivist)
  end
  describe "#user" do
    it "should get an existing user" do
      allow(User).to receive(:directory_attributes).and_return('{"attr":"abc"}')
      get :user, uid:@user.id
      expect(response).to be_success
      expect { JSON.parse(response.body) }.not_to raise_error
      results = JSON.parse(response.body)
      expect(results["attr"]).to eq("abc")
    end
  end
end
