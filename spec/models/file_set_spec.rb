# frozen_string_literal: true
require 'rails_helper'

describe FileSet, type: :model do
  let(:file) { build(:file_set, :with_png, label: 'sample_png') }
  before do
    allow(file).to receive(:mime_type).and_return('image/png')
  end

  subject { file }

  describe '::indexer' do
    subject { described_class.indexer }
    it { is_expected.to be(FileSetIndexer) }
  end

  describe '#.to_solr' do
    subject { file.to_solr }
    it { is_expected.to include(Solrizer.solr_name('file_format') => 'png') }
    it { is_expected.to include(Solrizer.solr_name('label') => 'sample_png') }
  end

  describe '#file_format' do
    its(:file_format) { is_expected.to eq('png') }
  end

  describe '#visibility' do
    context 'by default' do
      its(:visibility) { is_expected.to eq('restricted') }
      its(:public?) { is_expected.to be false }
      its(:registered?) { is_expected.to be false }
    end
  end

  describe '#time_uploaded' do
    context 'with a blank date_uploaded' do
      its(:time_uploaded) { is_expected.to be_blank }
    end
    context 'with date_uploaded' do
      let(:file) { build(:file_set, date_uploaded: Date.today) }
      its(:time_uploaded) { is_expected.to eq(Date.today.strftime('%Y-%m-%d %H:%M:%S')) }
    end
  end

  describe '#url' do
    its(:url) { is_expected.to end_with('/concern/file_sets/fixturepng') }
  end
end
