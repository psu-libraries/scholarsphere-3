# frozen_string_literal: true
require "rails_helper"

describe IngestFileJob do
  let(:user)     { create(:user) }
  let(:file_set) { create(:file_set, :with_png, depositor: user.login) }
  let(:filepath) { File.join(fixture_path, "world.png") }

  context "when adding a new version" do
    before { allow(CharacterizeJob).to receive(:perform_later) }

    it "updates the file set's title with the file name" do
      expect(file_set.title).to contain_exactly("Sample PNG")
      described_class.perform_now(file_set, filepath, user)
      expect(file_set.title).to contain_exactly("world.png")
    end
  end
end
