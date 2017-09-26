# frozen_string_literal: true

require 'rails_helper'

describe PublicFilteredList, type: :model do
  subject { described_class.new(file_list).filter }

  let(:file_list) do
    [create(:private_file, title: ['private']), create(:public_file, title: ['public'])]
  end

  it 'keeps public files' do
    expect(subject.count).to eq(1)
    expect(subject.map(&:title)).to include(['public'])
    expect(subject.map(&:title)).not_to include(['private'])
  end
end
