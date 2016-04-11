# frozen_string_literal: true
require 'spec_helper'
require 'support/vcr'

describe ShareNotifyJob do
  let(:user) { create(:jill) }
  let(:job)  { described_class.new(file.id) }
  let(:file) { create(:share_file) }

  before { allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(false) }

  context "with a shareable file" do
    before do
      allow_any_instance_of(GenericFileToShareJSONService)
        .to receive(:email_for_name)
        .and_return("kermit@muppets.org")
      WebMock.enable!
    end

    after { WebMock.disable! }

    describe "a successful outcome" do
      context "when it has not been sent to SHARE Notify" do
        before { allow(ShareNotify).to receive(:config) { { "token" => "SECRET_TOKEN" } } }

        it "sends a notification" do
          VCR.use_cassette('share_notify_success_job', record: :none) do
            expect(Sufia.queue).to receive(:push).with(an_instance_of(ShareNotifySuccessEventJob))
            job.run
          end
        end
      end

      context "when it has already been sent to SHARE Notify" do
        before { allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(true) }
        subject { job.run }
        it { is_expected.to be_nil }
      end
    end

    describe "an unsuccessful outcome" do
      let(:error_message) do
        "Posting file #{file.id} to SHARE Notify failed with 400. Response was {\"detail\"=>\"Invalid token.\"}"
      end

      before do
        allow(ShareNotify).to receive(:config) { { "token" => "BAD_TOKEN" } }
        allow_any_instance_of(ShareNotify::SearchResponse).to receive(:status).and_return(400)
      end

      it "logs the error" do
        VCR.use_cassette('share_notify_failed_job', record: :none) do
          expect(Rails.logger).to receive(:error).once.with(error_message)
          expect(Sufia.queue).to receive(:push).with(an_instance_of(ShareNotifyFailureEventJob))
          job.run
        end
      end
    end
  end

  context "with a file that cannot be shared" do
    let(:file) { create(:private_file) }
    subject { job.run }
    it { is_expected.to be_nil }
  end
end
