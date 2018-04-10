# frozen_string_literal: true

require 'rails_helper'

describe AliasManagementService do
  let(:service) { described_class.call(attributes) }
  let(:missing_agent) { I18n.t('scholarsphere.aliases.agent_error') }
  let(:missing_parameter) { I18n.t('scholarsphere.aliases.parameter_error') }
  let(:johnny_depp) { Agent.where(given_name: 'Johnny', sur_name: 'Depp').first }
  let(:depp) { Agent.where(given_name: nil, sur_name: 'Depp').first }
  let(:college_of_agriculture) { Agent.where(given_name: nil, sur_name: 'College of Agriculture').first }

  # Ensure that we have only one agent record for "Johnny Depp" with both first
  # and last names, and one agent record for "Depp" with only the last name.
  before do
    if Agent.where(given_name: 'Johnny', sur_name: 'Depp').empty?
      create(:agent, given_name: 'Johnny', sur_name: 'Depp')
    end
    if Agent.where(given_name: nil, sur_name: 'Depp').empty?
      Agent.create(sur_name: 'Depp')
    end
  end

  context 'with missing attributes' do
    let(:attributes) { {} }

    it 'raises an error' do
      expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
    end
  end

  context 'when an alias has no agent' do
    let(:alias_without_agent) { create(:alias, display_name: 'No Name') }

    context 'using the alias resource' do
      let(:attributes) { alias_without_agent }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_agent)
      end
    end

    context 'using the the id of the alias' do
      let(:attributes) { { id: alias_without_agent.id } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_agent)
      end
    end

    context 'using the the display name of the alias' do
      let(:attributes) { { display_name: alias_without_agent.display_name } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_agent)
      end
    end
  end

  context 'when the alias has an agent' do
    let!(:alias_with_agent) { create(:alias, display_name: 'Don Juan', agent: johnny_depp) }

    context 'using the alias resource' do
      let(:attributes) { alias_with_agent }

      it 'returns the alias' do
        expect { service }.to change(Alias, :count).by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end

    context 'using the the id of the alias' do
      let(:attributes) { { id: alias_with_agent.id } }

      it 'returns the alias' do
        expect { service }.to change(Alias, :count).by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end

    context 'using the the display name of the alias' do
      let(:attributes) { { display_name: alias_with_agent.display_name } }

      it 'returns the alias' do
        expect { service }.to change(Alias, :count).by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end
  end

  context 'when the agent exists but the alias does not' do
    let(:new_alias) { Alias.where(display_name: 'Capt. Jack Sparrow').first }

    before { Alias.destroy_all }

    context 'with all parameters' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', given_name: 'Johnny', sur_name: 'Depp' } }

      it 'returns a new alias for the agent' do
        expect { service }.to change(Alias, :count).by(1).and change(Agent, :count).by(0)
        expect(service.display_name).to eq('Capt. Jack Sparrow')
        expect(new_alias.agent).to eq(johnny_depp)
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', sur_name: 'Depp' } }

      it 'returns a new alias for the agent' do
        expect { service }.to change(Alias, :count).by(1).and change(Agent, :count).by(0)
        expect(service.display_name).to eq('Capt. Jack Sparrow')
        expect(new_alias.agent).to eq(depp)
      end
    end

    context 'with a missing surname' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', given_name: 'Johnny' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
      end
    end

    context 'with a missing display name' do
      let(:attributes) { { given_name: 'Johnny', sur_name: 'Depp' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
      end
    end

    context 'with only a display name' do
      let(:attributes) { { display_name: 'College of Agriculture' } }
      let(:new_alias)  { Alias.where(display_name: 'College of Agriculture').first }

      it 'returns a new alias for the agent' do
        expect { service }.to change(Alias, :count).by(1).and change(Agent, :count).by(1)
        expect(service.display_name).to eq('College of Agriculture')
        expect(new_alias.agent).to eq(college_of_agriculture)
      end
    end
  end

  context 'when neither alias nor agent exist' do
    before { Alias.destroy_all && Agent.destroy_all }

    context 'with all the required parameters' do
      let(:attributes) do
        {
          display_name: 'Commodore Barbarossa',
          given_name: 'Geoffrey',
          sur_name: 'Rush',
          email: 'pirate_barbossa@gmail.com',
          psu_id: 'gr01'
        }
      end

      let(:new_agent) { Agent.where(sur_name: 'Rush').first }

      it 'returns a new alias linked to a new agent' do
        expect { service }.to change(Alias, :count).by(1).and change(Agent, :count).by(1)
        expect(service.display_name).to eq('Commodore Barbarossa')
        expect(new_agent.email).to eq('pirate_barbossa@gmail.com')
        expect(new_agent.psu_id).to eq('gr01')
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', sur_name: 'Rush' } }

      it 'returns a new alias linked to a new agent' do
        expect { service }.to change(Alias, :count).by(1).and change(Agent, :count).by(1)
        expect(service.display_name).to eq('Commodore Barbarossa')
      end
    end

    context 'with a missing surname' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', given_name: 'Geoffrey' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
      end
    end

    context 'with a missing display name' do
      let(:attributes) { { given_name: 'Geoffrey', sur_name: 'Rush' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
      end
    end
  end
end
