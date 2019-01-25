# frozen_string_literal: true

require 'rails_helper'
require 'valkyrie/specs/shared_specs'

describe Valkyrie::Alias do
  subject(:valkyrie_alias) { described_class.new(agent_id: '123abc', display_name: 'Johnny Lately') }

  let(:agent) { Valkyrie::Agent.new(given_name: 'Johnny C. Lately', sur_name: 'Lately', psu_id: 'jcl81',
                                    email: 'newkid@example.com', orcid_id: '00123445', alias_ids: '123abc') }

  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#agent_id' do
    it 'contains the id' do
      expect(valkyrie_alias.agent_id.id).to eq('123abc')
    end
  end

  describe '#display_name' do
    its(:display_name) { is_expected.to eq('Johnny Lately') }
  end
end
