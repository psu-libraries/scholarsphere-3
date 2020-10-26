# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scholarsphere::Migration::Collection, type: :model do
  subject(:migration_collection) { described_class.new(collection) }

  let(:collection) { build(:public_collection, :with_complete_metadata) }

  describe '#metadata' do
    context 'when the collection has one title' do
      its(:metadata) { is_expected.to include(title: collection.title.first) }
    end

    context 'when the collection has multiple titles' do
      let(:collection) { build(:collection, title: ['title1', 'title2']) }

      it 'raises an error' do
        expect { migration_collection.metadata }.to raise_error(Scholarsphere::Migration::Error)
      end
    end

    context 'when migrating creators' do
      it 'buils a nested hash with the appropriate metadata' do
        expect(migration_collection.metadata[:creator_aliases_attributes].first[:alias]).to eq('creatorcreator')
      end
    end

    context 'with an original identifier' do
      its(:metadata) { is_expected.to include(noid: collection.id) }
    end

    context 'with keywords' do
      its(:metadata) { is_expected.to include(keyword: ['keyword hhh']) }
    end

    context 'with an original uploaded date' do
      its(:metadata) { is_expected.to include(deposited_at: collection.create_date) }
    end

    context 'when the published date is nil' do
      let(:collection) { build(:public_collection, :with_complete_metadata, date_created: []) }

      its(:metadata) { is_expected.to include(published_date: '') }
    end

    context 'with a single value for published date' do
      let(:collection) { build(:public_collection, :with_complete_metadata, date_created: ['two days before tomorrow']) }

      its(:metadata) { is_expected.to include(published_date: 'two days before tomorrow') }
    end

    context 'with multiple values for published date' do
      let(:collection) { build(:public_collection, :with_complete_metadata, date_created: ['yesterday', 'today', 'tomorrow']) }

      # @note order cannot be guaranteed
      its(:metadata) { is_expected.to include(published_date: collection.date_created.join(', ')) }
    end

    context 'with mulitple values for description' do
      let(:collection) { build(:public_collection, :with_complete_metadata, description: ['first', 'second', 'third']) }

      # @note order cannot be guaranteed
      its(:metadata) { is_expected.to include(description: collection.description.join(' ')) }
    end

    context 'when migrating identifiers' do
      let(:collection) { build(:public_collection, :with_complete_metadata) }

      its(:metadata) { is_expected.to include(identifier: collection.identifier) }
    end

    context 'when migrating dois' do
      let(:doi) { 'https://doi.org/10.18113/S1KW2H' }
      let(:identifiers) { ['asdf', doi] }
      let(:collection) { build(:public_collection, identifier: identifiers) }

      its(:metadata) { is_expected.to include(identifier: ['asdf'], doi: doi) }
    end
  end

  describe '#depositor' do
    its(:depositor) { is_expected.to include(psu_id: collection.depositor, surname: 'Example') }
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

  describe '#work_noids' do
    its(:work_noids) { is_expected.to be_empty }
  end
end
