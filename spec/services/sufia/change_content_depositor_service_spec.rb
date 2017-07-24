# frozen_string_literal: true
require 'rails_helper'

describe Sufia::ChangeContentDepositorService do
  let!(:depositor) { create(:user) }
  let!(:receiver)  { create(:user) }
  let!(:file)      { create(:file_set, :public, user: depositor) }
  let!(:work)      { create(:public_work, depositor: depositor.user_key) }

  before do
    work.members << file
    described_class.call(work, receiver, reset)
  end

  context 'by default, when permissions are not reset' do
    let(:reset) { false }

    it 'changes the depositor and records an original depositor' do
      work.reload
      expect(work.depositor).to eq receiver.user_key
      expect(work.proxy_depositor).to eq depositor.user_key
      expect(work.edit_users).to include(receiver.user_key, depositor.user_key)
      expect(work.visibility).to eq('open')
    end

    it 'changes the depositor of the child file sets' do
      file.reload
      expect(file.depositor).to eq receiver.user_key
      expect(file.edit_users).to include(receiver.user_key, depositor.user_key)
      expect(file.visibility).to eq('open')
    end
  end

  context 'when permissions are reset' do
    let(:reset) { true }

    it 'excludes the depositor from the edit users' do
      work.reload
      expect(work.depositor).to eq receiver.user_key
      expect(work.proxy_depositor).to eq depositor.user_key
      expect(work.edit_users).to contain_exactly(receiver.user_key)
      expect(work.visibility).to eq('restricted')
    end

    it 'changes the depositor of the child file sets' do
      file.reload
      expect(file.depositor).to eq receiver.user_key
      expect(file.edit_users).to contain_exactly(receiver.user_key)
      expect(file.visibility).to eq('restricted')
    end
  end
end
