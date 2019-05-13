# frozen_string_literal: true

require 'rails_helper'

describe UserStatsPresenter, type: :model do
  subject do
    described_class.new(
      start_date: Date.today.last_month.beginning_of_month,
      end_date: Date.today.last_month.end_of_month,
      user: user
    )
  end

  let(:user) { create(:user) }

  describe '#file_downloads' do
    before do
      UserStat.create(user_id: user.id, date: (Date.today.last_month.beginning_of_month + 10), file_downloads: 5)
      UserStat.create(user_id: user.id, date: (Date.today.last_month.beginning_of_month + 11), file_downloads: 20)
      UserStat.create(user_id: user.id, date: (Date.today.last_month.beginning_of_month + 12), file_downloads: 3)
    end

    its(:file_downloads) { is_expected.to eq(28) }
  end

  describe '#total_files' do
    let(:document) { FileSet.new(id: '123').to_solr.merge(creator_tesim: user.login) }

    before { index_document(document) }

    its(:total_files) { is_expected.to eq(1) }
  end
end
