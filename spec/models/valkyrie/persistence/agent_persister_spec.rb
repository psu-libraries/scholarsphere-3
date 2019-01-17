# frozen_string_literal: true

require 'rails_helper'
require 'valkyrie/specs/shared_specs'

describe Valkyrie::Persistence::AgentPersister do
  let(:adapter) { Valkyrie::Persistence::AgentAdapter.new }
  let(:persister) { described_class.new(adapter: adapter) }
  let(:query_service) { adapter.query_service }

  it_behaves_like 'a Valkyrie::Persister'

  context 'alias set' do
    let(:agent) do
      agent = Valkyrie::Agent.new(given_name: 'Johnny C.', sur_name: 'Lately', psu_id: 'jcl81',
                                  email: 'newkid@example.com', orcid_id: '00123445')
      agent.aliases = [{ display_name: 'Johnny Lately' }]
      agent
    end

    it 'saves an agent to fedora' do
      result = persister.save(resource: agent)
      fedora_agent = Agent.find(result.id.id)
      expect(fedora_agent.given_name).to eq('Johnny C.')
      expect(fedora_agent.sur_name).to eq('Lately')
      expect(fedora_agent.psu_id).to eq('jcl81')
      expect(fedora_agent.email).to eq('newkid@example.com')
      expect(fedora_agent.orcid_id).to eq('00123445')
      expect(fedora_agent.aliases.map(&:display_name)).to eq(['Johnny Lately'])
    end
  end

  context 'alias_id set' do
    let(:fedora_alias) { Alias.create(agent: nil, display_name: 'Johnny Come Lately') }
    let(:agent) { Valkyrie::Agent.new(given_name: 'Johnny C.', sur_name: 'Lately', psu_id: 'jcl81',
                                      email: 'newkid@example.com', orcid_id: '00123445',
                                      alias_ids: [fedora_alias.id]) }
    let(:fedora_agent) { build(:agent, :with_complete_metadata, aliases: [agent_alias]) }
    let(:agent_alias) { build(:alias) }

    it 'saves an agent to fedora' do
      result = persister.save(resource: agent)
      fedora_agent = Agent.find(result.id.id)
      expect(fedora_agent.given_name).to eq('Johnny C.')
      expect(fedora_agent.sur_name).to eq('Lately')
      expect(fedora_agent.psu_id).to eq('jcl81')
      expect(fedora_agent.email).to eq('newkid@example.com')
      expect(fedora_agent.orcid_id).to eq('00123445')
      expect(fedora_agent.aliases.map(&:display_name)).to eq(['Johnny Come Lately'])
    end

    it 'updates an agent to fedora' do
      fedora_agent.save!
      puts fedora_agent.id
      result = query_service.find_by(id: fedora_agent.id.to_s)
      expect(result.given_name).to eq('Johnny C.')
      expect(result.sur_name).to eq('Lately')
      expect(result.psu_id).to eq('jcl81')
      expect(result.email).to eq('newkid@example.com')
      expect(result.orcid_id).to eq('00123445')
      result.aliases = [{ display_name: 'Johnny Lately' }]
      result.given_name = 'Johnny'
      result2 = persister.save(resource: result)
      fedora_agent.reload
      expect(fedora_agent.aliases.map(&:display_name)).to eq(['Johnny Lately'])
      expect(result2.given_name).to eq('Johnny')
      expect(result2.alias_ids.map(&:id)).to eq(fedora_agent.aliases.map(&:id))
    end
  end
end
