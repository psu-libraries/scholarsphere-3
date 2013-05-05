require 'spec_helper'

describe ContentDepositorChangeEventJob do
  before do
    @depositor = FactoryGirl.find_or_create(:user)
    @receiver = FactoryGirl.find_or_create(:test_user_1)
    @file = GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(@depositor.user_key)
      gf.save!
    end
    ContentDepositorChangeEventJob.new(@file.pid, @receiver.user_key).run
  end
  after do
    @file.delete
  end
  it "should change the depositor to the new user, and record the original depositor as the proxy" do
      @file.reload
      @file.depositor.should == @receiver.user_key
      @file.proxy_depositor.should == @depositor.user_key
      @file.edit_users.should include(@receiver.user_key, @depositor.user_key)
  end
end
