require 'spec_helper'

describe StatsPresenter, type: :model do
  let(:end_datetime) { DateTime.now }
  let(:presenter) { described_class.new(start_datetime, end_datetime) }
  let(:system_stats) { double }

  before do
    allow(SystemStats).to receive(:new).with(5, start_datetime.to_s, end_datetime.to_s).and_return(system_stats)
  end

  describe "#single_day?" do
    subject { presenter.single_day? }

    context "start and end datetime on the same day" do
      let(:start_datetime) { DateTime.now }
      it { is_expected.to be_truthy }
    end

    context "start and end datetime on different days" do
      let(:start_datetime) { 1.day.ago }
      it { is_expected.to be_falsey }
    end
  end

  describe "#date_str" do
    subject { presenter.date_str }

    context "start and end datetime on the same day" do
      let(:start_datetime) { DateTime.now }
      it { is_expected.to eq(start_datetime.to_date.to_s) }
    end

    context "start and end datetime on different days" do
      let(:start_datetime) { 1.day.ago }
      it { is_expected.to include(start_datetime.to_date.to_s) }
      it { is_expected.to include(end_datetime.to_date.to_s) }
    end
  end

  describe "#start_date" do
    let(:start_datetime) { DateTime.parse("2004-01-01T01:01:01") }
    subject { presenter.start_date.to_s }
    it { is_expected.to eq "2004-01-01" }
  end

  describe "accessors" do
    let(:start_datetime) { DateTime.parse("2004-01-01T01:01:01") }
    it "responds to expected attributes" do
      expect(presenter).to respond_to(:total_users)
      expect(presenter).to respond_to(:total_uploads)
      expect(presenter).to respond_to(:total_public_uploads)
      expect(presenter).to respond_to(:total_registered_uploads)
      expect(presenter).to respond_to(:total_private_uploads)
      expect(presenter).to respond_to(:terms)
    end
  end

  describe "upload stats" do
    let(:start_datetime) { DateTime.parse("2004-01-01T01:01:01") }

    it "calls SystemStats for data" do
      expect(system_stats).to receive(:document_by_permission).and_return({ total: 100, public: 70, registered: 20, private: 10 })
      expect(presenter.total_uploads).to eq(100)
      expect(presenter.total_public_uploads).to eq(70)
      expect(presenter.total_registered_uploads).to eq(20)
      expect(presenter.total_private_uploads).to eq(10)
    end
  end

  describe "#total_users" do
    let(:start_datetime) { DateTime.parse("2004-01-01T01:01:01") }
    let(:mock_query) { double }

    before do
      allow(mock_query).to receive(:count).and_return(100)
    end

    it "calls SystemStats for data" do
      expect(system_stats).to receive(:recent_users).and_return(mock_query)
      expect(presenter.total_users).to eq(100)
    end
  end
end
