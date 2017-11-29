# frozen_string_literal: true

require 'rails_helper'

describe Agent do
  subject { build(:agent, :with_complete_metadata, aliases: [agent_alias]) }

  let(:agent_alias) { build(:alias) }

  describe '#given_name' do
    its(:given_name) { is_expected.to eq('Johnny C.') }
  end

  describe '#sur_name' do
    its(:sur_name) { is_expected.to eq('Lately') }
  end

  describe '#aliases' do
    its(:aliases) { is_expected.to contain_exactly(agent_alias) }
  end

  describe '#psu_id' do
    its(:psu_id) { is_expected.to eq('jcl81') }
  end

  describe '#email' do
    its(:email) { is_expected.to eq('newkid@example.com') }
  end

  describe '#orcid_id' do
    its(:orcid_id) { is_expected.to eq('00123445') }
  end
end
