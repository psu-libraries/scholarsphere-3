# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe AuditJob do
  before(:each) do
    @user = FactoryGirl.find_or_create(:user)
    @inbox = @user.mailbox.inbox
    @file = GenericFile.new
    @file.apply_depositor_metadata(@user.login)
    @file.save
  end
  describe "passing audit" do
    it "should not send passing mail" do
      ActiveFedora::RelsExtDatastream.any_instance.stub(:dsChecksumValid).and_return(true)
      AuditJob.new(@file.pid, "RELS-EXT", @file.rels_ext.versionID).run
      @inbox = @user.mailbox.inbox
      @inbox.count.should == 0
    end
  end
  describe "failing audit" do
    it "should send failing mail" do
      ActiveFedora::RelsExtDatastream.any_instance.stub(:dsChecksumValid).and_return(false)
      AuditJob.new(@file.pid, "RELS-EXT", @file.rels_ext.versionID).run
      @inbox = @user.mailbox.inbox
      @inbox.count.should == 1
      @inbox.each { |msg| msg.last_message.subject.should == AuditJob::FAIL }
    end
  end
end
