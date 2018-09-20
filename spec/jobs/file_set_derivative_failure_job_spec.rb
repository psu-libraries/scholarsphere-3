# frozen_string_literal: true

require 'rails_helper'

describe FileSetDerivativeFailureJob do
  let(:user)     { create(:user) }
  let(:file_set) { work.file_sets.first }

  let!(:work)    { create(:work, :with_one_file, user: user) }

  it 'sends an failed derivative message on a file set' do
    expect {
      described_class.perform_now(file_set, user)
    }.to change { file_set.events.length }.by(1)
  end

  context 'file set without a work' do
    let(:file_set) { create(:file_set, user: user) }

    it 'sends an failed derivative message on a file set' do
      expect {
        described_class.perform_now(file_set, user)
      }.to change { file_set.events.length }.by(1)
    end
  end
end
