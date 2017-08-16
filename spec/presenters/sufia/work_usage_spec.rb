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
end
