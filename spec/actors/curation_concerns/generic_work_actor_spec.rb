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

  context "creator set" do
    let(:attributes) { { creator: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'] } }
    it "keeps creator order" do
      expect(work.creator).to eq(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'])
    end
  end

  context "creator nil" do
    let(:attributes) { { creator: nil } }
    it "does not error" do
      expect(work.creator).to eq([])
    end
  end
end
