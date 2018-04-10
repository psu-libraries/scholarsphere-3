# frozen_string_literal: true

require 'rails_helper'

describe Alias do
  describe '#display_name' do
    subject { build(:alias, display_name: 'Some Name') }

    its(:display_name) { is_expected.to eq('Some Name') }
  end

  describe '##indexer' do
    subject { described_class.indexer }

    it { is_expected.to eq(AliasIndexer) }
  end

  describe '#agent' do
    let(:agent) { create(:agent) }
    let(:agent_alias) { create(:alias, display_name: 'The Real Joe Schmoe', agent: agent) }

    it 'links to the agent' do
      expect(agent_alias.agent.id).to eq(agent.id)
      expect(agent.aliases).to contain_exactly(agent_alias)
    end
  end
end
