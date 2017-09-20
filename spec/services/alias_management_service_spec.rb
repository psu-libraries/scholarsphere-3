# frozen_string_literal: true

require 'rails_helper'

describe AliasManagementService do
  let(:service) { described_class.call(attributes) }
  let(:person) { create(:person, given_name: 'Johnny', sur_name: 'Depp') }
  let(:missing_person) { I18n.t('scholarsphere.aliases.person_error') }
  let(:missing_parameter) { I18n.t('scholarsphere.aliases.parameter_error') }

  context 'with missing attributes' do
    let(:attributes) { {} }

    it 'raises an error' do
      expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
    end
  end

  context 'when an alias has no person' do
    let(:alias_without_person) { create(:alias, display_name: 'No Name') }

    context 'using the alias resource' do
      let(:attributes) { alias_without_person }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_person)
      end
    end

    context 'using the the id of the alias' do
      let(:attributes) { { id: alias_without_person.id } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_person)
      end
    end

    context 'using the the display name of the alias' do
      let(:attributes) { { display_name: alias_without_person.display_name } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_person)
      end
    end
  end

  context 'when the alias has a person' do
    let!(:alias_with_person) { create(:alias, display_name: 'Don Juan', person: person) }

    context 'using the alias resource' do
      let(:attributes) { alias_with_person }

      it 'returns the alias' do
        expect { service }.to change { Alias.count }.by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end

    context 'using the the id of the alias' do
      let(:attributes) { { id: alias_with_person.id } }

      it 'returns the alias' do
        expect { service }.to change { Alias.count }.by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end

    context 'using the the display name of the alias' do
      let(:attributes) { { display_name: alias_with_person.display_name } }

      it 'returns the alias' do
        expect { service }.to change { Alias.count }.by(0)
        expect(service.display_name).to eq('Don Juan')
      end
    end
  end

  context 'when the person exists but the alias does not' do
    before { Alias.destroy_all }

    context 'with all the required parameters' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', given_name: 'Johnny', sur_name: 'Depp' } }

      it 'returns a new alias for the person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(0)
        expect(service.display_name).to eq('Capt. Jack Sparrow')
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', sur_name: 'Depp' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
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
  end

  context 'when neither alias nor person exist' do
    before { Alias.destroy_all && Person.destroy_all }

    context 'with all the required parameters' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', given_name: 'Geoffrey', sur_name: 'Rush' } }

      it 'returns a new alias linked to a new person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(1)
        expect(service.display_name).to eq('Commodore Barbarossa')
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', sur_name: 'Rush' } }

      it 'raises an error' do
        expect { service }.to raise_error(AliasManagementService::Error, missing_parameter)
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
