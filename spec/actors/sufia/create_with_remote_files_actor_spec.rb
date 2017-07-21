# frozen_string_literal: true
require "rails_helper"

describe Sufia::CreateWithRemoteFilesActor do
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }

  let(:create_actor) do
    double("create actor", create: true,
                           curation_concern: work,
                           user: user)
  end
  let(:actor) do
    CurationConcerns::Actors::ActorStack.new(work, user, [described_class])
  end

  let(:remote_files) do
    [{ url: "file:///local/file/ pigs .txt",
       expires: "2014-03-31T20:37:36.214Z",
       file_name: "here.txt" }]
  end

  let(:attributes) { { remote_files: remote_files } }

  before do
    allow(CurationConcerns::Actors::RootActor).to receive(:new).and_return(create_actor)
    allow(create_actor).to receive(:create).and_return(true)
  end

  context "with local files" do
    it "attaches files with spaces" do
      expect(IngestLocalFileJob).to receive(:perform_later).with(FileSet, "/local/file/ pigs .txt", user)
      expect(actor.create(attributes)).to be true
    end
  end
end
