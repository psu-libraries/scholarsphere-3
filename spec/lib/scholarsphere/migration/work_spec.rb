# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Work, type: :model do
  subject(:migration_work) { described_class.new(work) }

  let(:work) { build(:public_work, :with_complete_metadata) }

  describe '#metadata' do
    context 'when the work has one title' do
      its(:metadata) { is_expected.to include(title: work.title.first) }
    end

    context 'when the work has multiple titles' do
      let(:work) { build(:work, title: ['title1', 'title2']) }

      it 'raises an error' do
        expect { migration_work.metadata }.to raise_error(Scholarsphere::Migration::Error)
      end
    end

    context 'when migrating creators' do
      it 'buils a nested hash with the appropriate metadata' do
        expect(migration_work.metadata[:creator_aliases_attributes].first[:alias]).to eq('creatorcreator')
      end
    end

    context 'with visibility' do
      its(:metadata) { is_expected.to include(visibility: 'open') }
    end

    context 'with an original identifier' do
      its(:metadata) { is_expected.to include(noid: work.id) }
    end

    context 'when the work is embargoed' do
      let(:embargo_date) { DateTime.now + 12.days }
      let(:work) { build(:work, :with_public_embargo, embargo_release_date: embargo_date) }

      its(:metadata) { is_expected.to include(embargoed_until: embargo_date.iso8601) }
    end

    context 'when the files are embargoed' do
      let(:embargo_date) { DateTime.now + 3.months }
      let(:fs1) { create(:file_set, embargo_release_date: (embargo_date - 1.month)) }
      let(:fs2) { create(:file_set, embargo_release_date: (embargo_date - 2.months)) }
      let(:fs3) { create(:file_set, embargo_release_date: embargo_date) }

      before do
        work.ordered_members << [fs1, fs3, fs2]
        work.thumbnail_id = fs1.id
      end

      its(:metadata) { is_expected.to include(embargoed_until: embargo_date.iso8601) }
    end

    context 'with keywords' do
      its(:metadata) { is_expected.to include(keyword: ['tagtag']) }
    end

    context 'with the original upload date' do
      its(:metadata) { is_expected.to include(deposited_at: work.date_uploaded) }
    end

    context 'when the published date is nil' do
      let(:work) { build(:public_work, :with_complete_metadata, date_created: []) }

      its(:metadata) { is_expected.to include(published_date: '') }
    end

    context 'with a single value for published date' do
      let(:work) { build(:public_work, :with_complete_metadata, date_created: ['two days before tomorrow']) }

      its(:metadata) { is_expected.to include(published_date: 'two days before tomorrow') }
    end

    context 'with multiple values for published date' do
      let(:work) { build(:public_work, :with_complete_metadata, date_created: ['yesterday', 'today', 'tomorrow']) }

      # @note order cannot be guaranteed
      its(:metadata) { is_expected.to include(published_date: work.date_created.join(', ')) }
    end

    context 'with mulitple values for description' do
      let(:work) { build(:public_work, :with_complete_metadata, description: ['first', 'second', 'third']) }

      # @note order cannot be guaranteed
      its(:metadata) { is_expected.to include(description: work.description.join(' ')) }
    end

    context 'when migrating identifiers' do
      let(:work) { build(:public_work, :with_complete_metadata) }

      its(:metadata) { is_expected.to include(identifier: work.identifier) }
    end

    context 'when migrating dois' do
      let(:doi) { 'https://doi.org/10.18113/S1KW2H' }
      let(:identifiers) { ['asdf', doi] }
      let(:work) { build(:public_work, identifier: identifiers) }

      its(:metadata) { is_expected.to include(identifier: ['asdf'], doi: doi) }
    end

    context 'with a single rights statement' do
      let(:work) { build(:public_work, :with_complete_metadata) }

      its(:metadata) { is_expected.to include(rights: work.rights.first) }
    end

    context 'with multiple rights statements' do
      let(:rights) do
        [
          'http://creativecommons.org/licenses/by-nc-nd/3.0/us/',
          'http://creativecommons.org/publicdomain/mark/1.0/'
        ]
      end

      let(:work) { build(:public_work, rights: rights) }

      its(:metadata) { is_expected.to include(rights: 'http://creativecommons.org/publicdomain/mark/1.0/') }
    end
  end

  describe '#depositor' do
    its(:depositor) { is_expected.to include(psu_id: 'user', surname: 'user') }
  end

  describe '#permissions' do
    its(:permissions) do
      is_expected.to eq(
        'read_users' => [],
        'read_groups' => [],
        'edit_users' => [],
        'edit_groups' => []
      )
    end
  end

  describe '#files' do
    let(:user) { create(:user) }
    let(:work) { create(:public_work_with_pdf, :with_complete_metadata, depositor: user.login) }

    before { allow_any_instance_of(CreateDerivativesJob).to receive(:perform) }

    context 'when the files exist' do
      its(:files) do
        is_expected.to include(
          file: an_instance_of(Pathname),
          deposited_at: work.file_sets.first.create_date,
          noid: an_instance_of(String)
        )
      end
    end

    context 'when the files do not exist' do
      let(:mock_location) { instance_double('FileSetDiskLocation', path: 'this/is/bogus') }

      before { allow(FileSetDiskLocation).to receive(:new).and_return(mock_location) }

      its(:files) { is_expected.to be_empty }
    end
  end
end
