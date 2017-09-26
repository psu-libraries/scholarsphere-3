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
end
