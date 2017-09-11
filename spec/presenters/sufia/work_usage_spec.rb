# frozen_string_literal: true

require 'rails_helper'

describe Sufia::WorkUsage do
  subject { described_class.new(work.id) }

  let(:work) { create(:work) }

  describe '#date_for_analytics' do
    context 'without date_uploaded' do
      its(:date_for_analytics) { is_expected.to eq(work.create_date) }
    end

    context 'when date_uploaded is before Sufia.config.analytic_start_date' do
      let(:work) { create(:work, date_uploaded: DateTime.new(2011, 7, 1)) }

      its(:date_for_analytics) { is_expected.to eq(Sufia.config.analytic_start_date) }
    end

    context 'when date_uploaded is after Sufia.config.analytic_start_date' do
      let(:work) { create(:work, date_uploaded: DateTime.new(2014, 7, 1)) }

      its(:date_for_analytics) { is_expected.to eq('July 1, 2014') }
    end
  end

  describe '#to_flots' do
    subject { described_class.new(work.id).send(:to_flots, stats) }

    let(:start_datetime) { 3.days.ago }
    let(:yesterday_stat) { WorkViewStat.new(work_id: 'abc123', date: 1.day.ago, work_views: 10) }
    let(:yesterday_flot) { yesterday_stat.to_flot }
    let(:five_days_ago_stat) { WorkViewStat.new(work_id: 'abc123', date: 5.days.ago, work_views: 15) }
    let(:five_days_ago_flot) { five_days_ago_stat.to_flot }
    let(:four_days_ago_stat) { WorkViewStat.new(work_id: 'abc123', date: 4.days.ago.to_date, work_views: 0) }
    let(:four_days_ago_flot) { four_days_ago_stat.to_flot }
    let(:three_days_ago_stat) { WorkViewStat.new(work_id: 'abc123', date: 3.days.ago.to_date, work_views: 0) }
    let(:three_days_ago_flot) { three_days_ago_stat.to_flot }
    let(:two_days_ago_stat) { WorkViewStat.new(work_id: 'abc123', date: 2.days.ago.to_date, work_views: 0) }
    let(:two_days_ago_flot) { two_days_ago_stat.to_flot }
    let(:stats) { [five_days_ago_stat, yesterday_stat] }

    context 'no days are present' do
      let(:stats) { [] }

      it { is_expected.to eq([]) }
    end

    context 'all days are present' do
      let(:stats) { [two_days_ago_stat, yesterday_stat] }

      it { is_expected.to eq([two_days_ago_flot, yesterday_flot]) }
    end

    context 'one day is missing' do
      let(:stats) { [three_days_ago_stat, yesterday_stat] }

      it { is_expected.to eq([three_days_ago_flot, two_days_ago_flot, yesterday_flot]) }
    end

    context 'multiple days are missing' do
      let(:stats) { [five_days_ago_stat, yesterday_stat] }

      it { is_expected.to eq([five_days_ago_flot, four_days_ago_flot,
                              three_days_ago_flot, two_days_ago_flot, yesterday_flot])}
    end
  end
end
