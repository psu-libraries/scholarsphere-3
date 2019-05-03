# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'scholarsphere:stats' do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/stats.rake"]
  end

  describe ':notify' do
    context 'when there are not stats to send' do
      it 'sends no emails' do
        expect(UserStatsNotificationJob).not_to receive(:perform_later)
        run_task('scholarsphere:stats:notify')
      end
    end

    context 'when a user has stats' do
      let(:user) { create(:user, email: 'nowhere@fake.com') }
      let(:message) { ActionMailer::Base.deliveries.first }

      before do
        allow(PsuDir::LdapUser).to receive(:check_ldap_exist!).with(user.login).and_return(true)
        UserStat.create(user_id: user.id, date: (Date.today.last_month.beginning_of_month + 10), file_downloads: 5)
      end

      it 'sends an email to the user' do
        run_task('scholarsphere:stats:notify')
        expect(message.to).to contain_exactly('nowhere@fake.com')
        expect(message.from).to contain_exactly(ENV['no_reply_email'])
        expect(message.subject).to eq('ScholarSphere - Reporting Monthly Downloads and Views')
      end
    end
  end
end
