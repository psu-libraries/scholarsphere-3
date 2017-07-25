# frozen_string_literal: true
require 'rails_helper'

describe Devise::Strategies::HttpHeaderAuthenticatable do
  subject { described_class.new(nil) }
  before { allow(subject).to receive(:request).and_return(request) }

  describe '#valid_user?' do
    context 'in a production environment' do
      let(:production) { ActiveSupport::StringInquirer.new('production') }
      before { allow(Rails).to receive(:env).and_return(production) }
      context 'using REMOTE_USER' do
        let(:request) { double(headers: { 'REMOTE_USER' => 'abc123' }) }
        it { is_expected.to be_valid }
      end
      context 'using HTTP_REMOTE_USER' do
        let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'abc123' }) }
        it { is_expected.not_to be_valid }
      end
      context 'using no header' do
        let(:request) { double(headers: {}) }
        it { is_expected.not_to be_valid }
      end
    end
    context 'in a development or test environment' do
      context 'using REMOTE_USER' do
        let(:request) { double(headers: { 'REMOTE_USER' => 'abc123' }) }
        it { is_expected.to be_valid }
      end
      context 'using HTTP_REMOTE_USER' do
        let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'abc123' }) }
        it { is_expected.to be_valid }
      end
      context 'using no header' do
        let(:request) { double(headers: {}) }
        it { is_expected.not_to be_valid }
      end
    end
  end

  describe 'authenticate!' do
    let(:user) { create(:archivist) }
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => user.login }) }
    context 'with a new user' do
      before { allow(User).to receive(:find_by_login).with(user.login).and_return(nil) }
      it 'populates LDAP attrs' do
        expect(User).to receive(:create).with(login: user.login, email: user.login).once.and_return(user)
        expect_any_instance_of(User).to receive(:populate_attributes).once
        expect(subject).to be_valid
        expect(subject.authenticate!).to eq(:success)
      end
    end
    context 'with an existing user' do
      before { allow(User).to receive(:find_by_login).with(user.login).and_return(user) }
      it 'does not populate LDAP attrs' do
        expect(User).to receive(:create).with(login: user.login).never
        expect_any_instance_of(User).to receive(:populate_attributes).never
        expect(subject).to be_valid
        expect(subject.authenticate!).to eq(:success)
      end
    end
  end
end
