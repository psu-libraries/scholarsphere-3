require 'spec_helper'

describe ProxyDepositRequest do
  after(:all) do
    GenericFile.destroy_all
  end
  let (:sender) { FactoryGirl.find_or_create(:user) }
  let (:receiver) { FactoryGirl.find_or_create(:test_user_1) }
  let (:file) do
    GenericFile.new.tap do |f|
      f.title = "Test file"
      f.apply_depositor_metadata('jcoyne')
      f.save!
    end
  end

  subject { ProxyDepositRequest.new(pid: file.pid, sending_user: sender, receiving_user: receiver, sender_comment: "please take this") }

  its(:status) {should == 'pending'}
  it {should be_pending}
  its(:fulfillment_date) {should be_nil}
  its(:sender_comment) {should == 'please take this'}
  it "should have a solr_doc for the file" do
    subject.solr_doc.title.should == 'Test file'
  end


  context "After approval" do
    before do
      subject.transfer!
    end
    its(:status) {should == 'accepted'}
    its(:fulfillment_date) {should_not be_nil}
  end

  context "After rejection" do
    before do
      subject.reject!('a comment')
    end
    its(:status) {should == 'rejected'}
    its(:fulfillment_date) {should_not be_nil}
    its(:receiver_comment) {should == 'a comment'}
  end

  context "After cancel" do
    before do
      subject.cancel!
    end
    its(:status) {should == 'canceled'}
    its(:fulfillment_date) {should_not be_nil}
  end

  describe "transfer" do
    describe "when the transfer_to field is set" do
      describe "and the user isn't found" do
        it "should be an error" do
          subject.transfer_to = 'dave'
          subject.should_not be_valid
          subject.errors[:transfer_to].should == ["must be an existing user"]
        end
      end

      describe "and the user is found" do
        it "should create a transfer_request" do
          subject.transfer_to = receiver.user_key
          subject.save!
          proxy_request = receiver.proxy_deposit_requests.first
          proxy_request.pid.should == file.pid
          proxy_request.sending_user.should == sender
        end
      end
    end
  end
end
