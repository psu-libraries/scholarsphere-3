# frozen_string_literal: true

require 'rails_helper'

describe AliasIndexer do
  let(:agent) { build :agent, given_name: 'Sue', sur_name: 'Doe' }
  let(:alias_item) { build :alias, id: '123abc', agent: agent }
  let(:indexer) { described_class.new(alias_item) }

  describe '#generate_solr_document' do
    subject { solr_doc }

    let(:solr_doc) { indexer.generate_solr_document }

    it { is_expected.to include('agent_name_tesim' => 'Sue Doe') }
  end
end
