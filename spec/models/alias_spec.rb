# frozen_string_literal: true

require 'rails_helper'

describe Alias do
  describe '#display_name' do
    subject { build(:alias, display_name: 'Some Name') }

    its(:display_name) { is_expected.to eq('Some Name') }
  end

  describe '#person' do
    let(:person) { create(:person) }
    let(:person_alias) { create(:alias, display_name: 'The Real Joe Schmoe', person: person) }

    it 'links to the person' do
      expect(person_alias.person.id).to eq(person.id)
      expect(person.aliases).to contain_exactly(person_alias)
    end
  end
end
