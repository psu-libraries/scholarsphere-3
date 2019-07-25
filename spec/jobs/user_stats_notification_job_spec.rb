# frozen_string_literal: true

require 'rails_helper'

describe UserStatsNotificationJob do
  let(:user) { create(:user) }
  let(:start_date) { Date.today - 10 }
  let(:end_date) { Date.today }

  context 'when the user exists in LDAP and wants to receive stats email' do
    let(:mock_mailer) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(PsuDir::LdapUser).to receive(:check_ldap_exist!).with(user.login).and_return(true)
    end

    it 'sends the email to the user' do
      expect(UserMailer).to receive(:user_stats_email)
        .with(user: user, start_date: start_date, end_date: end_date)
        .and_return(mock_mailer)
      expect(mock_mailer).to receive(:deliver_now)
      described_class.perform_now(id: user.id, start_date: start_date, end_date: end_date)
    end
  end

  context 'when the user exists in LDAP and DOES NOT want to receive stats email' do
    let(:mock_mailer) { instance_double(ActionMailer::MessageDelivery) }
    let(:user) { create :user, opt_out_stats_email: true }

    before do
      allow(PsuDir::LdapUser).to receive(:check_ldap_exist!).with(user.login).and_return(true)
    end

    it 'does not send the email to the user' do
      expect(UserMailer).not_to receive(:user_stats_email)
    end
  end

  context 'when the user does not exist in LDAP' do
    before do
      allow(PsuDir::LdapUser).to receive(:check_ldap_exist!).with(user.login).and_return(false)
    end

    it 'does not send the email to the user' do
      expect(described_class.perform_now(id: user.id, start_date: start_date, end_date: end_date)).to be_nil
    end
  end
end
