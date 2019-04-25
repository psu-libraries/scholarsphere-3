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
      let(:user) { create(:user) }

      before do
        UserStat.create(user_id: user.id, date: (Date.today.last_month.beginning_of_month + 10), file_downloads: 5)
      end

      it 'sends an email to the user' do
        expect(UserStatsNotificationJob).to receive(:perform_later)
        run_task('scholarsphere:stats:notify')
      end
    end
  end
end
