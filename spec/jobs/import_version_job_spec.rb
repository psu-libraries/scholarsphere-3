# frozen_string_literal: true
require 'rails_helper'

describe ImportVersionJob do
  let(:user)         { create(:user) }
  let(:work)         { create(:public_work_with_png, depositor: user.login) }
  let(:file)         { File.join(Dir.tmpdir, 'world.png') }
  let(:fixture_file) { File.join(fixture_path, 'world.png') }
  let(:file_set)     { work.file_sets.first }

  before do
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
    FileUtils.cp fixture_file, file
  end

  it 'characterizes the file and then deletes it' do
    expect(CharacterizeJob).to receive(:perform_now).once
    described_class.perform_now(file_set, file)
    expect(File.exist?(file)).to be_falsey
  end
end
