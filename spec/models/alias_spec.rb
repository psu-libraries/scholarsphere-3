# frozen_string_literal: true

require 'rails_helper'

describe Alias do
  describe '#display_name' do
    subject { build(:alias, display_name: 'Some Name') }

    its(:display_name) { is_expected.to eq('Some Name') }
  end

  describe '#person' do
    let(:person) { create(:person) }
    let(:aliaz)  { create(:alias, display_name: 'The Real Joe Schmoe', person: person) }

    it 'links to the person' do
      expect(aliaz.person.id).to eq(person.id)
      expect(person.aliases).to contain_exactly(aliaz)
    end
  end
end
