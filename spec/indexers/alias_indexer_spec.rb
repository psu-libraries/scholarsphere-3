# frozen_string_literal: true

require 'rails_helper'

describe AliasIndexer do
  let(:agent) { create :agent, given_name: 'Sue', sur_name: 'Doe' }
  let(:alias_item) { create :alias, agent: agent }
  let(:indexer) { described_class.new(alias_item) }

  describe '#generate_solr_document' do
    subject { solr_doc }

    let(:solr_doc) { indexer.generate_solr_document }

    it { is_expected.to include('agent_name_tesim' => 'Sue Doe') }

    context 'additional aliases' do
      let(:alias2) { create :alias, agent: agent, display_name: 'mickey mouse' }

      before do
        alias_item
        alias2
      end
      it { is_expected.to include('agent_name_tesim' => 'Sue Doe, mickey mouse') }
    end
  end
end
