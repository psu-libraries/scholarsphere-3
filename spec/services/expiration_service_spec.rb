# frozen_string_literal: true

require 'rails_helper'

describe ExpirationService do
  let(:lease_date) { (Time.zone.today + 7.days) }
  let(:leased_work) { create(:public_work, :with_public_lease, title: ['Leased Work'], lease_expiration_date: lease_date) }
  let(:embargo_date) { (Time.zone.today + 14.days) }
  let(:embargoed_work) { create(:private_work, :with_public_embargo, title: ['Embargoed Work'], embargo_release_date: embargo_date) }

  after(:all) { ActiveFedora::Cleaner.clean! }

  context 'with an expired lease' do
    it 'changes the visibility' do
      expect(leased_work.visibility).to eq('open')
      expect(VisibilityCopyJob).to receive(:perform_later).with(leased_work)
      described_class.call(lease_date)
      leased_work.reload
      expect(leased_work.visibility).to eq('restricted')
      expect(leased_work.lease.lease_history.first).to start_with('An active lease was deactivated')
    end
  end

  context 'with an unexpired lease' do
    it 'does not change the visibility when it has not expired' do
      expect(leased_work.visibility).to eq('open')
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(leased_work)
      described_class.call
      leased_work.reload
      expect(leased_work.visibility).to eq('open')
      expect(leased_work.lease.lease_history).to be_empty
    end
  end

  context 'with a previously expired lease' do
    before do
      leased_work.deactivate_lease!
      leased_work.lease.save
    end
    it 'does not change the visibility' do
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(leased_work)
      described_class.call(lease_date)
    end
  end

  context 'with an expired embargo' do
    it 'changes the visibility when it has expired' do
      expect(embargoed_work.visibility).to eq('restricted')
      expect(VisibilityCopyJob).to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
      embargoed_work.reload
      expect(embargoed_work.visibility).to eq('open')
      expect(embargoed_work.embargo.embargo_history.first).to start_with('An active embargo was deactivated')
    end
  end

  context 'with an unexpired embargo' do
    it 'does not change the visibility when it has not expired' do
      expect(embargoed_work.visibility).to eq('restricted')
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(embargoed_work)
      described_class.call
      embargoed_work.reload
      expect(embargoed_work.visibility).to eq('restricted')
      expect(embargoed_work.embargo.embargo_history).to be_empty
    end
  end

  context 'with a previously expired embargo' do
    before do
      embargoed_work.deactivate_embargo!
      embargoed_work.embargo.save
    end
    it 'does not change the visibility' do
      expect(VisibilityCopyJob).not_to receive(:perform_later).with(embargoed_work)
      described_class.call(embargo_date)
    end
  end
end
