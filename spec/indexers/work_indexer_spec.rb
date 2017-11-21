# frozen_string_literal: true

require 'rails_helper'

describe WorkIndexer do
  include FactoryHelpers

  let(:file_set) { build(:file_set) }
  let(:work)     { build(:work, representative: file_set,
                                keyword: ['Bird']) }
  let(:indexer)  { described_class.new(work) }

  let(:file) do
    mock_file_factory(
      mime_type: 'image/jpeg',
      format_label: ['JPEG Image'],
      height: ['500'],
      width: ['600'],
      file_size: ['12']
    )
  end

  describe '#generate_solr_document' do
    subject { solr_doc }

    let(:solr_doc) { indexer.generate_solr_document }

    it { is_expected.to include('bytes_lts' => 0) }

    describe 'file_format' do
      subject { solr_doc[Solrizer.solr_name('file_format', :facetable)] }

      context 'with a file containing technical metadata' do
        before { allow(file_set).to receive(:original_file).and_return(file) }
        it { is_expected.to eq('jpeg (JPEG Image)') }
      end

      context 'without a file' do
        it { is_expected.to be_nil }
      end

      context 'without a representative' do
        before { allow(work).to receive(:representative).and_return(nil) }
        it { is_expected.to be_nil }
      end
    end

    describe 'a groomed document' do
      let(:creator) { build(:alias, display_name: 'BIG. DISPLAY Name') }
      let(:agent)   { Agent.new(given_name: 'BIG.', sur_name: 'Name') }

      before do
        allow(work).to receive(:creators).and_return([creator])
        allow(creator).to receive(:agent).and_return(agent)
      end

      it { is_expected.to include('creator_name_sim' => ['Big Name'],
                                  'creator_name_tesim' => ['BIG. DISPLAY Name'],
                                  'keyword_sim' => ['bird'],
                                  'keyword_tesim' => ['Bird']) }

      it { is_expected.not_to include('creator_name_sim' => ['BIG. Name'], 'creator_name_tesim' => ['Big Display Name']) }
    end
  end
end
