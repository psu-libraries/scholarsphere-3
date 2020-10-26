# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::DateValidator do
  subject { described_class.call(date) }

  context 'with an existing DateTime' do
    let(:date) { DateTime.now }

    it { is_expected.to eq(date) }
  end

  context 'with a parseable string' do
    let(:date) { '2012-09-12T00:08:25Z' }

    it { is_expected.to eq(DateTime.parse('2012-09-12T00:08:25Z')) }
  end

  context 'with a nil date' do
    let(:date) { nil }

    it { is_expected.to be_nil }
  end

  context 'with an unparseable date string' do
    let(:date) { 'cantparsethis' }

    it 'raises and error' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
