# frozen_string_literal: true

require 'rails_helper'

describe CurationConcerns::Actors::GenericWorkActor do
  let(:user) { create(:user) }
  let(:work) { build(:work, user: user) }

  let(:actor_stack) { CurationConcerns::Actors::ActorStack.new(work, user, [described_class]) }

  before do
    actor_stack.create(attributes)

    # saving work to be certain we are looking at the work in the repository
    work.save
    work.reload
  end

  context 'with ordered attributes' do
    let(:attributes) do
      {
        creator: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'],
        title: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']
      }
    end

    it 'keeps the correct order' do
      expect(work.creator).to eq(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
      expect(work.title).to eq(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
    end
  end

  context 'creator nil' do
    let(:attributes) { { creator: nil } }

    it 'does not error' do
      expect(work.creator).to eq([])
    end
  end

  context 'when uploading on behalf of another user' do
    subject { work }

    let(:other_user) { create(:user) }
    let(:attributes) { { title: ['Sample'], on_behalf_of: other_user.login } }

    its(:depositor) { is_expected.to eq(other_user.login) }
  end
end
