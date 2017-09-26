# frozen_string_literal: true

require 'rails_helper'

describe GenericWork do
  subject { work }

  let(:work) { create(:work) }

  it 'creates a noid on save' do
    expect(subject.id.length).to eq 10
  end

  describe '#time_uploaded' do
    context 'with a blank date_uploaded' do
      its(:time_uploaded) { is_expected.to be_blank }
    end
    context 'with date_uploaded' do
      before { allow(work).to receive(:date_uploaded).and_return(Date.today) }
      its(:time_uploaded) { is_expected.to eq(Date.today.strftime('%Y-%m-%d %H:%M:%S')) }
    end
  end

  describe '#url' do
    its(:url) { is_expected.to end_with("/concern/generic_works/#{work.id}") }
  end

  describe '::indexer' do
    subject { described_class }

    its(:indexer) { is_expected.to eq(WorkIndexer) }
  end

  describe '#bytes' do
    let(:file_size_field)  { work.send(:file_size_field)  }
    let(:file1)            { build(:file_set, id: 'fs1')  }
    let(:file2)            { build(:file_set, id: 'fs2')  }

    before do
      ActiveFedora::Cleaner.cleanout_solr
      ActiveFedora::SolrService.add(file1.to_solr.merge!(file_size_field.to_sym => '1024'))
      ActiveFedora::SolrService.add(file2.to_solr.merge!(file_size_field.to_sym => '1024'))
      ActiveFedora::SolrService.commit
      allow(work).to receive(:member_ids).and_return(['fs1', 'fs2'])
    end
    its(:bytes) { is_expected.to eq(2048) }
  end

  describe '#upload_set' do
    its(:upload_set) { is_expected.to be_blank }
  end
end
