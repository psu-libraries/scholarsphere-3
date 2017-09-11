# frozen_string_literal: true

require 'rails_helper'

describe Person do
  describe '::find_or_create' do
    subject(:person) { described_class.find_or_create(attrs) }

    before { described_class.destroy_all }

    let!(:joe_jones) { create(:person, first_name: 'Joe', last_name: 'Jones') }
    let!(:joe_smith) { create(:person, first_name: 'Joe', last_name: 'Smith') }

    context 'with an ID that matches an existing record' do
      let!(:attrs) { { id: joe_jones.id, first_name: 'something' } }

      it 'finds the existing record' do
        expect { person }.to change { described_class.count }.by(0)
        expect(person).to eq joe_jones
      end
    end

    context 'with no ID, but attributes match an existing record' do
      let!(:attrs) { { first_name: joe_jones.first_name, last_name: joe_jones.last_name } }

      it 'finds the existing record' do
        expect { person }.to change { described_class.count }.by(0)
        expect(person).to eq joe_jones
      end
    end

    context 'attributes dont match any existing record' do
      let!(:attrs) { { first_name: joe_jones.first_name, last_name: 'Something Else' } }

      it 'creates a new Person record' do
        expect { person }.to change { described_class.count }.by(1)
        expect(person.first_name).to eq 'Joe'
        expect(person.last_name).to eq 'Something Else'
      end
    end
  end
end
