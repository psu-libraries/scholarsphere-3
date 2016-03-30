# frozen_string_literal: true
require 'spec_helper'
require 'support/vcr'

describe ShareNotifyDeleteJob do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:file) { create(:file) }
  let(:job)  { described_class.new(file.id) }

  context "when the file has been sent to SHARE" do
    before do
      allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(true)
      allow(ShareNotify).to receive(:config) { { "token" => "SECRET_TOKEN" } }
      allow_any_instance_of(GenericFileToShareJSONService)
        .to receive(:email_for_name)
        .and_return("kermit@muppets.org")
      WebMock.enable!
    end

    after do
      WebMock.disable!
    end

    it "sends a notification" do
      VCR.use_cassette('share_notify_success_job', record: :none) do
        expect(Sufia.queue).to receive(:push).with(an_instance_of(ShareNotifyDeleteEventJob))
        job.run
      end
    end
  end
end
