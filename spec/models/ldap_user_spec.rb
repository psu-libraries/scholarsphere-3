# frozen_string_literal: true

require 'rails_helper'

describe LdapUser do
  let(:user)        { ['mocked ldap user'] }
  let(:empty_user)  { User.new }

  # You'll need to change these if I ever go meet Elvis
  let(:psu_user)        { 'agw13' }
  let(:psu_user_groups) { 'umg/up.dlt.scholarsphere-admin' }

  describe '::get_user' do
    before { allow(Hydra::LDAP).to receive(:get_user).and_return(user) }
    subject { described_class.get_user('filter') }

    context 'when LDAP is responding' do
      it { is_expected.to eq(user) }
    end
    context 'when LDAP is unwilling' do
      before { allow(described_class).to receive(:unwilling?).and_return(true) }
      it { is_expected.to be_empty }
    end
    context 'when LDAP is unwilling less than the number of tries' do
      before { allow(described_class).to receive(:unwilling?).at_most(6).times }
      it { is_expected.to eq(user) }
    end
  end

  describe '::check_ldap_exist!' do
    context 'when the login is not present' do
      subject { described_class.check_ldap_exist!(nil) }

      it { is_expected.to be false }
    end
    context 'when the user is empty' do
      subject { described_class.check_ldap_exist!(empty_user) }

      it { is_expected.to be false }
    end
    context 'when the user is present' do
      before { allow(Hydra::LDAP).to receive(:does_user_exist?).and_return(true) }
      subject { described_class.check_ldap_exist!(user) }

      it { is_expected.to be true }

      context 'when LDAP is unwilling' do
        let(:message) { 'LDAP is unwilling to perform this operation, try upping the number of tries' }

        before { allow(described_class).to receive(:unwilling?).and_return(true) }
        it 'retries the required number of times' do
          expect(described_class).to receive(:unwilling?).at_most(7).times
          expect(described_class).to receive(:sleep).at_most(7).times
          expect(Rails.logger).to receive(:warn).exactly(:once).with(message)
          expect(described_class.check_ldap_exist!(user)).to be false
        end
      end

      context 'when LDAP is willing' do
        before { allow(described_class).to receive(:unwilling?).and_return(false) }
        it 'does not retry' do
          expect(described_class).not_to receive(:sleep)
          expect(Rails.logger).not_to receive(:warn)
          expect(described_class.check_ldap_exist!(user)).to be true
        end
      end

      context 'when Hydra::LDAP raises an error' do
        let(:message) { 'Error getting LDAP response' }

        before { allow(Hydra::LDAP).to receive(:does_user_exist?).and_raise(Net::LDAP::Error) }
        it 'does not retry, but logs the error and returns false' do
          expect(described_class).not_to receive(:sleep)
          expect(Rails.logger).to receive(:warn).with(/message/)
          expect(described_class.check_ldap_exist!(user)).to be false
        end
      end
    end
  end

  describe '::get_groups' do
    context 'when the login is not present' do
      subject { described_class.get_groups(nil) }

      it { is_expected.to be_empty }
    end
    context 'when the user is present' do
      before { allow(described_class).to receive(:group_response_from_ldap).and_return(ldap_results) }
      subject { described_class.get_groups(user) }

      context 'with groups' do
        let(:ldap_results) do
          [
            { psmemberof:
              [
                'cn=umg/up.its.wikispaces.users.admin,dc=psu,dc=edu',
                'cn=umg/up.its.ipv6_planning_team,dc=psu,dc=edu',
                'cn=xyz/agw13.all.stars,dc=psu,dc=edu'
              ] }
          ]
        end

        it { is_expected.to eq(['umg/up.its.wikispaces.users.admin', 'umg/up.its.ipv6_planning_team']) }
      end
      context 'without groups' do
        let(:ldap_results) { [{ psmemberof: [] }] }

        it { is_expected.to be_empty }
      end
      context 'when the ldap response is empty' do
        let(:ldap_results) { [] }

        it { is_expected.to be_empty }
      end
    end
    context 'with a real PSU user', :need_ldap, unless: ENV['TRAVIS'] do
      subject { described_class.get_groups(psu_user) }

      it { is_expected.to include(psu_user_groups) }
    end
  end

  describe '::filter_for' do
    context 'with students, faculty, staff, and employees' do
      subject { described_class.filter_for(:student, :faculty, :staff, :employee) }

      let(:result) { '(| (eduPersonPrimaryAffiliation=STUDENT) (eduPersonPrimaryAffiliation=FACULTY) (eduPersonPrimaryAffiliation=STAFF) (eduPersonPrimaryAffiliation=EMPLOYEE))))' }

      it { is_expected.to eq(result) }
    end
    context 'with nobody' do
      subject { described_class.filter_for }

      it { is_expected.to be_empty }
    end
  end
end
