# frozen_string_literal: true
require 'spec_helper'

describe ZoteroSubscription do
  let!(:users) { [User.create(login: 'zzz'), User.create(login: 'abc111', zotero_userid: 'abc', arkivo_token: '123abc'), User.create(login: 'def333', zotero_userid: 'def', arkivo_token: 'def333', arkivo_subscription: 'subscribed')] }
  let(:job) { double }
  # let(:chain) { double }
  describe "#call" do
    it "Creates a subscription job for users with no subscription" do
      expect(Sufia::Arkivo::CreateSubscriptionJob).to receive(:new).with('abc111').and_return(job)
      expect(Sufia::Arkivo::CreateSubscriptionJob).not_to receive(:new).with('def333')
      expect(Sufia::Arkivo::CreateSubscriptionJob).not_to receive(:new).with('zzz')
      expect(job).to receive(:run)
      described_class.call
    end
  end
end
