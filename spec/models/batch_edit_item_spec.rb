# frozen_string_literal: true

require 'rails_helper'

describe BatchEditItem do
  subject { described_class.new(batch: [work1.id, work2.id]) }

  let(:work1) { create(:private_work) }
  let(:work2) { create(:private_work) }

  describe '#batch' do
    its(:batch) { is_expected.to contain_exactly(work1, work2) }
  end

  describe '#visibility' do
    context 'when all items in the batch have the same visibility' do
      its(:visibility) { is_expected.to eq('restricted') }
    end

    context 'when items in the batch have different visibilities' do
      let(:work2) { create(:public_work) }

      its(:visibility) { is_expected.to be_nil }
    end
  end

  describe '#creators' do
    context 'with unique creators' do
      let(:creator1) { create(:alias, display_name: 'First Creator', agent: Agent.new(given_name: 'First', sur_name: 'Creator')) }
      let(:creator2) { create(:alias, display_name: 'Second Creator', agent: Agent.new(given_name: 'Second', sur_name: 'Creator')) }
      let(:work1) { create(:work, title: ['First batch work'], creators: [creator1]) }
      let(:work2) { create(:work, title: ['Second batch work'], creators: [creator2]) }

      its(:creators) { is_expected.to contain_exactly(creator1, creator2) }
    end

    context 'with duplicate creators' do
      let(:creator1) { create(:alias, display_name: 'First Creator', agent: Agent.new(given_name: 'First', sur_name: 'Creator')) }
      let(:creator2) { create(:alias, display_name: 'Second Creator', agent: Agent.new(given_name: 'Second', sur_name: 'Creator')) }
      let(:work1) { create(:work, title: ['First batch work'], creators: [creator1, creator2]) }
      let(:work2) { create(:work, title: ['Second batch work'], creators: [creator1, creator2]) }

      its(:creators) { is_expected.to contain_exactly(creator1, creator2) }
    end
  end
end
