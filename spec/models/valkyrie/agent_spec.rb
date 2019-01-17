# frozen_string_literal: true

require 'rails_helper'
require 'valkyrie/specs/shared_specs'

describe Valkyrie::Agent do
  subject(:agent) { described_class.new(given_name: 'Johnny C.', sur_name: 'Lately', psu_id: 'jcl81',
                                        email: 'newkid@example.com', orcid_id: '00123445', alias_ids: '123abc') }

  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#given_name' do
    its(:given_name) { is_expected.to eq('Johnny C.') }
  end

  describe '#sur_name' do
    its(:sur_name) { is_expected.to eq('Lately') }
  end

  describe '#alias_ids' do
    it 'contains the ids' do
      expect(agent.alias_ids.map(&:id)).to contain_exactly('123abc')
    end
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
