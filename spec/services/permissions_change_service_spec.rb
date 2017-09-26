# frozen_string_literal: true

require 'rails_helper'

describe PermissionsChangeService do
  let(:user)            { double('stubbed user') }
  let(:batch_user)      { double('stubbed batch user') }
  let(:message)         { 'You can now edit file title' }
  let(:message_subject) { 'Permission change notification' }
  let(:generic_work)    { double('stubbed file', id: '1234', title: 'title') }
  let(:state)           { double('subbed permission change set') }
  let(:permissions)     { [{ name: 'abd123', type: 'person', access: 'edit' }] }
  let(:service) { described_class.new(state, generic_work) }

  before do
    allow(User).to receive(:find_by_user_key).and_return(user)
    allow(User).to receive(:batchuser).and_return(batch_user)
    allow(service).to receive(:unshareable?).and_return(true)
  end

  context 'permissions no change' do
    before { allow(state).to receive(:unchanged?).and_return(true) }
    it 'notifies no one' do
      expect(batch_user).not_to receive(:send_message)
      expect(service.call).to be_nil
    end
  end
  context 'permissions added' do
    before do
      allow(state).to receive(:unchanged?).and_return(false)
      allow(state).to receive(:added).and_return(permissions)
    end
    it 'notifies one user added' do
      expect(batch_user).to receive(:send_message).with(user, message, message_subject)
      expect(service.call).to be_nil
    end
  end
  context 'permissions removed' do
    before do
      allow(state).to receive(:unchanged?).and_return(false)
      allow(state).to receive(:added).and_return([])
    end
    it 'notifies no one' do
      expect(batch_user).not_to receive(:send_message)
      expect(service.call).to be_nil
    end
  end

  context 'with SHARE Notify' do
    before do
      allow(service).to receive(:unshareable?).and_return(false)
      allow(state).to receive(:unchanged?).and_return(false)
      allow(state).to receive(:added).and_return([])
    end
    context 'if the file has been privatized' do
      before do
        allow(state).to receive(:privatized?).and_return(true)
        allow(state).to receive(:publicized?).and_return(false)
      end
      it 'deletes the file from SHARE' do
        expect(ShareNotifyDeleteJob).to receive(:perform_later)
        expect(ShareNotifyJob).not_to receive(:perform_later)
        expect(service.call).to be_nil
      end
    end
    context 'if the file has been publicized' do
      before do
        allow(state).to receive(:privatized?).and_return(false)
        allow(state).to receive(:publicized?).and_return(true)
      end
      it 'sends the file to SHARE' do
        expect(ShareNotifyDeleteJob).not_to receive(:perform_later)
        expect(ShareNotifyJob).to receive(:perform_later)
        expect(service.call).to be_nil
      end
    end
  end
end
