require 'spec_helper'

describe AuditJob, :type => :model do
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @inbox = @user.mailbox.inbox
    @file = GenericFile.new
    @file.apply_depositor_metadata(@user.login)
    @file.save
  end
  describe "passing audit" do
    it "should not send passing mail" do
      allow_any_instance_of(ActiveFedora::RelsExtDatastream).to receive(:dsChecksumValid).and_return(true)
      AuditJob.new(@file.pid, "RELS-EXT", @file.rels_ext.versionID).run
      @inbox = @user.mailbox.inbox
      expect(@inbox.count).to eq(0)
    end
  end
  describe "failing audit" do
    it "should send failing mail" do
      allow_any_instance_of(ActiveFedora::RelsExtDatastream).to receive(:dsChecksumValid).and_return(false)
      AuditJob.new(@file.pid, "RELS-EXT", @file.rels_ext.versionID).run
      @inbox = @user.mailbox.inbox
      expect(@inbox.count).to eq(1)
      @inbox.each { |msg| expect(msg.last_message.subject).to eq(AuditJob::FAIL) }
    end
  end
end
