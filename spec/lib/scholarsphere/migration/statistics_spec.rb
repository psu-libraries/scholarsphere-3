# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Statistics do
  describe '#build' do
    let(:csv) { Rails.root.join('statistics.csv').read }
    let(:work) { create(:work, :with_one_file) }
    let(:today) { Time.zone.parse('2020-06-23') }
    let(:yesterday) { Time.zone.parse('2020-06-22') }

    before do
      FileViewStat.create(date: yesterday, views: 1, file_id: work.file_sets.first.id)
      FileViewStat.create(date: today, views: 1, file_id: work.file_sets.first.id)
      WorkViewStat.create(date: today, work_views: 2, work_id: work.id)
      FileDownloadStat.create(date: today, downloads: 2, file_id: work.file_sets.first.id)
      described_class.call
    end

    specify do
      expect(csv).to eq(
        "#{work.id},#{yesterday.iso8601},1\n" + \
        "#{work.id},#{today.iso8601},3\n" + \
        "#{work.file_sets.first.id},#{today.iso8601},2\n"
      )
    end
  end
end
