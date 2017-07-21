# frozen_string_literal: true
require "rails_helper"

describe AttachFilesToWorkJob do
  let(:user)          { create(:user) }
  let(:work)          { create(:work, depositor: user.login) }
  let(:file)          { File.open(File.join(fixture_path, "world.png")) }
  let(:uploaded_file) { Sufia::UploadedFile.create(file: file, user: user) }
  let(:job)           { described_class.new(work, [uploaded_file]) }

  before do
    QueuedFile.create(work_id: work.id, file_id: uploaded_file.id)
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
  end

  context "when the file is successfully added" do
    it "sends a success message" do
      expect(AttachFilesToWorkSuccessService).to receive(:new).with(user, kind_of(File)).and_call_original
      expect(CharacterizeJob).to receive(:perform_later).once
      expect { job.perform_now }.to change { QueuedFile.count }.by(-1)
    end
  end

  context "when the file is not successfully added" do
    let(:bad_actor) { double(CurationConcerns::Actors::FileSetActor) }
    before do
      allow(bad_actor).to receive(:create_content).with(file).and_return(false)
      allow(bad_actor).to receive(:user).and_return(user)
    end
    it "sends a success message" do
      expect(AttachFilesToWorkFailureService).to receive(:new).with(user, kind_of(File)).and_call_original
      job.send(:add_file, bad_actor, file)
    end
  end
end
