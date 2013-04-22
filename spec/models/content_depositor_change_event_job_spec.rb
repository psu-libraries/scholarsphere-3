require 'spec_helper'

describe ContentDepositorChangeEventJob do
  before do
    @depositor = FactoryGirl.find_or_create(:user)
    @receiver = FactoryGirl.find_or_create(:test_user_1)
    @file = GenericFile.new()
    @file.apply_depositor_metadata(@depositor.user_key)
    @file.save!
    ContentDepositorChangeEventJob.new(@file.pid, @receiver.user_key).run
  end
  after do
    @file.delete
  end
  it "should change the depositor to the new user, and record the original depositor as the proxy" do
      # User.any_instance.should_receive(:can?).with(:edit, @file).and_return(false)
      # User.any_instance.should_receive(:can?).with(:edit, @file2).and_return(false)
      @file.reload
      @file.depositor.should == @receiver.user_key
      @file.proxy_depositor.should == @depositor.user_key
      @file.edit_users.should == [@receiver.user_key]
  end
end
