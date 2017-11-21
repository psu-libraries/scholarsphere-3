# frozen_string_literal: true

require 'rails_helper'

describe IndexesCreator do
  subject { TestIndexer.new(work).generate_solr_document }

  let(:work)    { build(:work) }
  let(:creator) { build(:alias, display_name: 'Display Name') }

  before(:all) do
    class TestIndexer < ActiveFedora::IndexingService
      include IndexesCreator
    end
  end

  after(:all) do
    ActiveSupport::Dependencies.remove_constant('TestIndexer')
  end

  before do
    allow(work).to receive(:creators).and_return([creator])
    allow(creator).to receive(:agent).and_return(agent)
  end

  describe '#generate_solr_document' do
    context 'with a first and last name' do
      let(:agent) { Agent.new(given_name: 'First', sur_name: 'Last') }

      it { is_expected.to include('creator_name_tesim' => ['Display Name'], 'creator_name_sim' => ['First Last']) }
    end

    context 'with only a first name' do
      let(:agent) { Agent.new(given_name: 'First Only') }

      it { is_expected.to include('creator_name_tesim' => ['Display Name'], 'creator_name_sim' => ['First Only']) }
    end

    context 'with only a last name' do
      let(:agent) { Agent.new(sur_name: 'Only Last') }

      it { is_expected.to include('creator_name_tesim' => ['Display Name'], 'creator_name_sim' => ['Only Last']) }
    end

    context 'with no Agent' do
      let(:agent) { nil }

      it { is_expected.to include('creator_name_tesim' => ['Display Name'], 'creator_name_sim' => ['Display Name']) }
    end
  end
end
