# frozen_string_literal: true

require 'rails_helper'

describe Collection do
  subject { collection }

  describe 'setting creators' do
    before { Person.destroy_all }

    let(:collection) do
      described_class.new do |c|
        c.title = ['asdf']
        c.apply_depositor_metadata('asdf')
      end
    end

    # Record for Lucy already exists
    let!(:lucy) { create(:person, first_name: 'Lucy', last_name: 'Lee') }
    let(:fred_attrs) { { first_name: 'Fred', last_name: 'Jones' } }

    it 'finds or creates the Person records' do
      expect do
        collection.creators = [lucy, fred_attrs]
        collection.save!
      end.to change { Person.count }.by(1)

      expect(collection.creators).to include lucy
      expect(collection.creators.map(&:first_name)).to contain_exactly('Fred', 'Lucy')
    end
  end

  context 'with no attached files' do
    let(:collection) { build(:collection) }

    its(:bytes) { is_expected.to eq(0) }
  end

  context 'with attached files' do
    let!(:collection) { create(:public_collection, members: [work1, work2]) }

    let(:work1)       { build(:public_work, id: '1') }
    let(:work2)       { build(:public_work, id: '2') }
    let(:resp) do
      [{ Solrizer.solr_name(:file_size, CurationConcerns::CollectionIndexer::STORED_LONG) => '20' }]
    end

    before { allow(ActiveFedora::SolrService).to receive(:query).and_return(resp) }
    its(:bytes) { is_expected.to eq(40) }
  end

  describe '::indexer' do
    let(:collection) { described_class }

    its(:indexer) { is_expected.to eq(CollectionIndexer) }
  end

  context 'with a new collection' do
    let(:collection) { build(:collection) }

    it { is_expected.not_to be_private_access }
    it { is_expected.to be_open_access }
  end
end
