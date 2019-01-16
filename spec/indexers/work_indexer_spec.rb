# frozen_string_literal: true

require 'rails_helper'

describe WorkIndexer do
  include FactoryHelpers

  subject { solr_doc }

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

  let(:solr_doc) { indexer.generate_solr_document }

  it { is_expected.to include('bytes_lts' => 0) }

  describe 'the file format field' do
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

    it { expect(subject).to include('creator_name_sim' => ['Big Name'],
                                    'creator_name_tesim' => ['BIG. DISPLAY Name'],
                                    'keyword_sim' => ['bird'],
                                    'keyword_tesim' => ['Bird']) }

    it { is_expected.not_to include('creator_name_sim' => ['BIG. Name'], 'creator_name_tesim' => ['Big Display Name']) }
  end

  describe 'the readme file' do
    subject { solr_doc['readme_file_ss'] }

    before { allow(work).to receive(:readme_file).and_return(readme_file) }

    context 'with no readme file' do
      let(:readme_file) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the readme file as no content' do
      let(:readme_file) { build(:file_set) }

      it { is_expected.to be_nil }
    end

    context 'with a README file in non-UTF-8 format' do
      let(:readme_file) { build(:file_set) }

      # @note reading the file in binary mode results in an ASCII-8BIT
      let(:file) do
        mock_file_factory(
          mime_type: 'text/plain',
          content: File.open(File.join(fixture_path, 'bad_readme.md'), 'rb').read
        )
      end

      before { allow(readme_file).to receive(:original_file).and_return(file) }

      it 'encodes the content using UTF-8 replacing invalid characters with a ?' do
        expect(file.content.encoding.name).to eq('ASCII-8BIT')
        expect(solr_doc['readme_file_ss'].encoding.name).to eq('UTF-8')
        expect(solr_doc['readme_file_ss']).to include('incorrect dashes ��� are replaced with default characters.')
      end
    end
  end
end
