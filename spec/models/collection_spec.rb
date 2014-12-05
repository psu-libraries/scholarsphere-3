require 'spec_helper'

describe Collection, :type => :model do
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @collection = Collection.create(title: "test collection")
    @collection.apply_depositor_metadata(@user.user_key)
  end
  it "should have open visibility" do
    @collection.save
    expect(@collection.datastreams["rightsMetadata"].permissions({group:"public"})).to eq "read"
  end
end
