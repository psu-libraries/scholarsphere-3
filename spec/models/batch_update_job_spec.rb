# encoding: UTF-8
require 'spec_helper'

describe BatchUpdateJob, :type => :model do
  before do
    @user = FactoryGirl.find_or_create(:user)
    @batch = Batch.create
    @file = GenericFile.new(batch: @batch).tap do |f|
      f.apply_depositor_metadata(@user.user_key)
      f.save
    end
    @file2 = GenericFile.new(batch: @batch).tap do |f|
      f.apply_depositor_metadata('otherUser')
      f.save
    end
  end
  after do
    @batch.delete
    @file.delete
    @file2.delete
  end
  describe "failing update" do
    it "should check permissions for each file before updating" do
      expect_any_instance_of(User).to receive(:can?).with(:edit, @file).and_return(false)
      expect_any_instance_of(User).to receive(:can?).with(:edit, @file2).and_return(false)
      params = {'generic_file' => {'read_groups_string' => '', 'read_users_string' => 'archivist1, archivist2', 'tag' => ['']}, 'id' => @batch.pid, 'controller' => 'batch', 'action' => 'update'}.with_indifferent_access
      BatchUpdateJob.new(@user.user_key, params).run
      expect(@user.mailbox.inbox[0].messages[0].subject).to eq("Batch upload permission denied")
      @user.mailbox.inbox[0].messages[0].move_to_trash @user
    end
  end
  describe "passing update" do
    it "should log a content update event" do
      expect_any_instance_of(User).to receive(:can?).with(:edit, @file).and_return(true)
      expect_any_instance_of(User).to receive(:can?).with(:edit, @file2).and_return(true)
      s1 = double('one')
      expect(ContentUpdateEventJob).to receive(:new).with(@file.pid, @user.user_key).and_return(s1)
      expect(Sufia.queue).to receive(:push).with(s1).once
      s2 = double('two')
      expect(ContentUpdateEventJob).to receive(:new).with(@file2.pid, @user.user_key).and_return(s2)
      expect(Sufia.queue).to receive(:push).with(s2).once
      params = {'generic_file' => {'read_groups_string' => '', 'read_users_string' => 'archivist1, archivist2', 'tag' => ['“patience”']}, 'id' => @batch.pid, 'controller' => 'batch', 'action' => 'update'}.with_indifferent_access
      BatchUpdateJob.new(@user.user_key, params).run
      expect(@user.mailbox.inbox[0].messages[0].subject).to eq("Batch upload complete")
      @user.mailbox.inbox[0].messages[0].move_to_trash @user
      file = GenericFile.find(@file.pid)
      expect(file.tag).to eq(['“patience”'])
    end
  end
end
