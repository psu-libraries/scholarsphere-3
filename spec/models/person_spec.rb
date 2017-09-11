# frozen_string_literal: true

require 'rails_helper'

describe Person do
  describe '::find_or_create' do
    subject(:person) { described_class.find_or_create(attrs) }

    before { described_class.destroy_all }

    let!(:joe_jones) { create(:person, given_name: 'Joe', sur_name: 'Jones') }
    let!(:joe_smith) { create(:person, given_name: 'Joe', sur_name: 'Smith') }

    context 'with an ID that matches an existing record' do
      let!(:attrs) { { id: joe_jones.id, given_name: 'something' } }

      it 'finds the existing record' do
        expect { person }.to change { described_class.count }.by(0)
        expect(person).to eq joe_jones
      end
    end

    context 'with no ID, but attributes match an existing record' do
      let!(:attrs) { { given_name: joe_jones.given_name, sur_name: joe_jones.sur_name } }

      it 'finds the existing record' do
        expect { person }.to change { described_class.count }.by(0)
        expect(person).to eq joe_jones
      end
    end

    context 'attributes dont match any existing record' do
      let!(:attrs) { { given_name: joe_jones.given_name, sur_name: 'Something Else' } }

      it 'creates a new Person record' do
        expect { person }.to change { described_class.count }.by(1)
        expect(person.given_name).to eq 'Joe'
        expect(person.sur_name).to eq 'Something Else'
      end
    end
  end
end
