# frozen_string_literal: true

require 'rails_helper'

describe GenericWork do
  subject { work }

  context 'without any creators' do
    let(:work) { build(:work) }

    its(:creators) { is_expected.to be_empty }
    its(:creator_ids) { is_expected.to be_empty }
  end

  context 'when changing creator order' do
    let(:creator1) { create(:alias, display_name: 'Huey', agent: Agent.new(given_name: 'Huey', sur_name: 'Duck')) }
    let(:creator2) { create(:alias, display_name: 'Dewey', agent: Agent.new(given_name: 'Dewey', sur_name: 'Duck')) }
    let(:creator3) { create(:alias, display_name: 'Louis', agent: Agent.new(given_name: 'Louis', sur_name: 'Duck')) }
    let(:work) { create(:work, creators: [creator1, creator2, creator3]) }

    it 'saves the original order and changes it after saving' do
      expect(work.creator_ids).to eq([creator1.id, creator2.id, creator3.id])
      expect(work.creators).to eq([creator1, creator2, creator3])
      work.creators = [creator3, creator1, creator2]
      work.save
      work.reload
      expect(work.creator_ids).to eq([creator3.id, creator1.id, creator2.id])
      expect(work.creators).to eq([creator3, creator1, creator2])
    end
  end
end
