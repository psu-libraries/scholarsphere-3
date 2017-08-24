# frozen_string_literal: true

require 'rails_helper'

describe SolrDocumentGroomer do
  let(:legend)   { create(:creator, first_name: 'I AM', last_name: 'LEGEND') }
  let(:will)     { create(:creator, first_name: 'Will I.', last_name: 'Am') }

  let(:work)     { create(:work, creators: [legend, will], keyword: ['CAPITAL', 'Title.']) }
  let(:document) { SolrDocument.new(work.to_solr) }

  describe '#groom' do
    before { described_class.call(document) }

    context 'with normalized fields' do
      subject { document.fetch('creator_name_sim') }

      it { is_expected.to contain_exactly('I Am Legend', 'Will I Am') }
    end

    context 'with downcased fields' do
      subject { document.fetch('keyword_sim') }

      it { is_expected.to contain_exactly('capital', 'title') }
    end
  end
end
