# frozen_string_literal: true
require 'rails_helper'

describe AttachFilesToWorkJob do
  let(:user)             { create(:user) }
  let(:work)             { create(:work, depositor: user.login) }
  let(:file)             { File.open(File.join(fixture_path, "world.png")) }
  let(:uploaded_file)    { Sufia::UploadedFile.create(file: file, user: user) }

  before do
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
    QueuedFile.create(work_id: work.id, file_id: uploaded_file.id)
  end

  it "adds the file set to the process list" do
    expect(CharacterizeJob).to receive(:perform_later).once
    expect { described_class.perform_now(work, [uploaded_file]) }.to change { QueuedFile.count }.by(-1)
  end
end
