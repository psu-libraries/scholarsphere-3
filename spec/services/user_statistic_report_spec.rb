# frozen_string_literal: true

require 'rails_helper'

describe GoogleAnalytics::UserStatisticReport do
  let(:importer) { described_class.new(user1) }
  let(:user1)    { create(:user) }
  let(:user2)    { create(:user) }
  let(:results)  { described_class.new(user1).call }

  describe '#tally_user_results' do
    subject { results }

    let(:user1_work) { create :work, depositor: user1.login }
    let(:user1_file_set) { create :file_set, user: user1 }

    context 'no statuses are available' do
      it { is_expected.to be_empty }
    end

    context 'people have viewed and downloaded the objects' do
      let(:day1)            { Date.parse('2017-08-15') }
      let(:day2)            { Date.parse('2017-08-16') }
      let(:user2_file_set)  { create(:file_set, user: user2) }
      let(:user2_work)      { create(:work, depositor: user2.login) }
      let(:user1_work2)     { create(:work, depositor: user1.login) }
      let(:user1_file_set2) { create(:file_set, user: user1) }

      before do
        WorkViewStat.create date: day1, work_id: user1_work.id, user_id: user1.id, work_views: 2
        WorkViewStat.create date: day2, work_id: user1_work.id, user_id: user1.id, work_views: 2
        WorkViewStat.create date: day1, work_id: user2_work.id, user_id: user2.id, work_views: 1
        WorkViewStat.create date: day2, work_id: user2_work.id, user_id: user1.id, work_views: 2
        WorkViewStat.create date: day1, work_id: user1_work2.id, user_id: user1.id, work_views: 3
        FileViewStat.create date: day1, file_id: user1_file_set2.id, user_id: user1.id, views: 25
        FileViewStat.create date: day1, file_id: user1_file_set.id, user_id: user1.id, views: 5
        FileViewStat.create date: day1, file_id: user2_file_set.id, user_id: user2.id, views: 3
        FileDownloadStat.create(date: day2, file_id: user1_file_set.id, user_id: user1.id, downloads: 6)
      end
      it 'creates view entries in user table' do
        results = importer.call

        expect(results['2017-08-15 00:00:00 UTC']).to include(views: 30, work_views: 5)
        expect(results['2017-08-16 00:00:00 UTC']).to include(downloads: 6, work_views: 2)
      end
    end
  end
end
