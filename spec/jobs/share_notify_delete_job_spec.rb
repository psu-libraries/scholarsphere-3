# frozen_string_literal: true
require 'rails_helper'
require 'support/vcr'

describe ShareNotifyDeleteJob do
  let(:user) { create(:jill) }
  let(:work) { create(:share_file, depositor: user.login) }

  context 'when the file has been sent to SHARE' do
    before do
      allow_any_instance_of(GenericWork).to receive(:share_notified?).and_return(true)
      allow(ShareNotify).to receive(:config) { { 'token' => 'SECRET_TOKEN' } }
      allow_any_instance_of(GenericWorkToShareJSONService)
        .to receive(:email_for_name)
        .and_return('kermit@muppets.org')
      WebMock.enable!
    end

    after do
      WebMock.disable!
    end

    it 'sends a notification' do
      VCR.use_cassette('share_notify_success_job', record: :none) do
        expect(ShareNotifyDeleteEventJob).to receive(:perform_now)
        described_class.perform_now(work)
      end
    end
  end
end
