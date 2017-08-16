# frozen_string_literal: true

require 'rails_helper'

describe StatsPresenter, type: :model do
  let(:end_datetime) { DateTime.now }
  let(:presenter)    { described_class.new(start_datetime, end_datetime) }
  let(:system_stats) { double }
  let(:work_stats)   { double }

  before do
    allow(Sufia::Statistics::SystemStats).to receive(:new).with(5, start_datetime, end_datetime).and_return(system_stats)
    allow(Sufia::Statistics::Works::Count).to receive(:new).with(start_datetime, end_datetime).and_return(work_stats)
  end

  describe '#single_day?' do
    subject { presenter.single_day? }

    context 'start and end datetime on the same day' do
      let(:start_datetime) { DateTime.now }

      it { is_expected.to be_truthy }
    end

    context 'start and end datetime on different days' do
      let(:start_datetime) { 1.day.ago }

      it { is_expected.to be_falsey }
    end
  end

  describe '#date_str' do
    subject { presenter.date_str }

    context 'start and end datetime on the same day' do
      let(:start_datetime) { DateTime.now }

      it { is_expected.to eq(start_datetime.to_date.to_s) }
    end

    context 'start and end datetime on different days' do
      let(:start_datetime) { 1.day.ago }

      it { is_expected.to include(start_datetime.to_date.to_s) }
      it { is_expected.to include(end_datetime.to_date.to_s) }
    end
  end

  describe '#start_date' do
    subject { presenter.start_date.to_s }

    let(:start_datetime) { DateTime.parse('2004-01-01T01:01:01') }

    it { is_expected.to eq '2004-01-01' }
  end

  describe 'accessors' do
    let(:start_datetime) { DateTime.parse('2004-01-01T01:01:01') }

    it 'responds to expected attributes' do
      expect(presenter).to respond_to(:total_users)
      expect(presenter).to respond_to(:total_uploads)
      expect(presenter).to respond_to(:total_public_uploads)
      expect(presenter).to respond_to(:total_registered_uploads)
      expect(presenter).to respond_to(:total_private_uploads)
      expect(presenter).to respond_to(:terms)
    end
  end

  describe 'upload stats' do
    let(:start_datetime) { DateTime.parse('2004-01-01T01:01:01') }
    let(:stats) { { total: 100, public: 70, registered: 20, private: 10 } }

    before { allow(work_stats).to receive(:by_permission).and_return(stats) }
    it 'calls Sufia::Statistics::Works::Count for data' do
      expect(presenter.total_uploads).to eq(100)
      expect(presenter.total_public_uploads).to eq(70)
      expect(presenter.total_registered_uploads).to eq(20)
      expect(presenter.total_private_uploads).to eq(10)
    end
  end

  describe '#total_users' do
    let(:start_datetime) { DateTime.now }

    before { 3.times { create(:user) } }
    it 'returns the total number of user records' do
      expect(presenter.total_users).to eq(3)
    end
  end
end
