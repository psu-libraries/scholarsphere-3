# frozen_string_literal: true

require 'rails_helper'

describe Sufia::QueryService do
  let(:service) { described_class.new }

  describe '#build_date_query' do
    subject { described_class.new.build_date_query(start_date, end_date) }

    context 'with an end date' do
      let(:start_date) { DateTime.iso8601('1981-04-17', Date::ENGLAND) }
      let(:end_date) { DateTime.iso8601('1995-07-04', Date::ENGLAND) }

      it { is_expected.to eq('date_uploaded_dtsi:[1981-04-17T00:00:00Z TO 1995-07-04T00:00:00Z]') }
    end

    context 'without an end date' do
      let(:start_date) { DateTime.iso8601('1981-04-17', Date::ENGLAND) }
      let(:end_date) { nil }

      it { is_expected.to eq('date_uploaded_dtsi:[1981-04-17T00:00:00Z TO *]') }
    end
  end
end
