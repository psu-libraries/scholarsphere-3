# frozen_string_literal: true

require 'rails_helper'

describe AliasManagementService do
  let(:service) { described_class.call(attributes) }
  let(:missing_person) { I18n.t('scholarsphere.aliases.person_error') }
  let(:missing_parameter) { I18n.t('scholarsphere.aliases.parameter_error') }
  let(:johnny_depp) { Person.where(given_name: 'Johnny', sur_name: 'Depp').first }
  let(:depp) { Person.where(given_name: nil, sur_name: 'Depp').first }

  # Ensure that we have only one person record for "Johnny Depp" with both first
  # and last names, and one person record for "Depp" with only the last name.
  before do
    if Person.where(given_name: 'Johnny', sur_name: 'Depp').empty?
      create(:person, given_name: 'Johnny', sur_name: 'Depp')
    end
    if Person.where(given_name: nil, sur_name: 'Depp').empty?
      Person.create(sur_name: 'Depp')
    end
  end

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
    let!(:alias_with_person) { create(:alias, display_name: 'Don Juan', person: johnny_depp) }

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
    let(:new_alias) { Alias.where(display_name: 'Capt. Jack Sparrow').first }

    before { Alias.destroy_all }

    context 'with all parameters' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', given_name: 'Johnny', sur_name: 'Depp' } }

      it 'returns a new alias for the person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(0)
        expect(service.display_name).to eq('Capt. Jack Sparrow')
        expect(new_alias.person).to eq(johnny_depp)
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Capt. Jack Sparrow', sur_name: 'Depp' } }

      it 'returns a new alias for the person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(0)
        expect(service.display_name).to eq('Capt. Jack Sparrow')
        expect(new_alias.person).to eq(depp)
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

    context 'with all parameters' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', given_name: 'Geoffrey', sur_name: 'Rush' } }

      it 'returns a new alias linked to a new person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(1)
        expect(service.display_name).to eq('Commodore Barbarossa')
      end
    end

    context 'with a missing given name' do
      let(:attributes) { { display_name: 'Commodore Barbarossa', sur_name: 'Rush' } }

      it 'returns a new alias linked to a new person' do
        expect { service }.to change { Alias.count }.by(1).and change { Person.count }.by(1)
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
