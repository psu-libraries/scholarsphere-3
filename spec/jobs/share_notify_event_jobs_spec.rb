# frozen_string_literal: true

require 'rails_helper'

describe ShareNotify do
  let(:user) { create(:jill) }
  let(:file) { create(:work) }

  shared_examples 'a SHARE Notify event job' do
    it 'sends an event to the file activity stream' do
      expect {
        described_class.perform_now(file, user)
      }.to change { file.events.length }.by(1)
    end
  end

  describe ShareNotifySuccessEventJob do
    it_behaves_like 'a SHARE Notify event job'
  end

  describe ShareNotifyFailureEventJob do
    it_behaves_like 'a SHARE Notify event job'
  end

  describe ShareNotifyDeleteEventJob do
    it_behaves_like 'a SHARE Notify event job'
  end

  describe ShareNotifyDeleteFailureEventJob do
    it_behaves_like 'a SHARE Notify event job'
  end
end
