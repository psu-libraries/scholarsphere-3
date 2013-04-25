require 'spec_helper'

describe ProxyDepositRequest do
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
end
