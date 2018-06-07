# frozen_string_literal: true

require 'rails_helper'

describe Sufia::CreateWithFilesActor do
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }

  let(:create_actor) do
    double('create actor', create: true,
                           curation_concern: work,
                           user: user)
  end
  let(:actor) do
    CurationConcerns::Actors::ActorStack.new(work, user, [described_class])
  end

  before do
    allow(CurationConcerns::Actors::RootActor).to receive(:new).and_return(create_actor)
    allow(create_actor).to receive(:create).and_return(true)
  end

  context 'when specifying an embargo' do
    let(:uploaded_file) { Sufia::UploadedFile.create(user_id: user.id) }
    let(:visibility_attributes) do
      {
        visibility: 'embargo',
        visibility_during_embargo: 'restricted',
        embargo_release_date: '2020-06-08',
        visibility_after_embargo: 'open'
      }
    end

    let(:attributes) do
      visibility_attributes.merge(uploaded_files: [uploaded_file])
    end

    it 'passes the visibility attributes to the job' do
      expect(AttachFilesToWorkJob).to receive(:perform_later)
        .with(work, [uploaded_file], visibility_attributes)
      actor.create(attributes)
    end
  end
end
