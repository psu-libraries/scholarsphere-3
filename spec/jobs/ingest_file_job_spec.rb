# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe IngestFileJob do
  context 'when adding a new version', unless: external_files? do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login) }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it "updates the file set's title with the file name" do
      expect(file_set.title).to contain_exactly('Sample PNG')
      described_class.perform_now(file_set, filepath, user)
      expect(file_set.title).to contain_exactly('world.png')
    end
  end

  context 'fedora external content', if: external_files? do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login, id: 'mst3kabc') }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
      described_class.perform_now(file_set, filepath, user)
    end

    after do
      file_set.delete
      file_set.eradicate
      if Rails.env.test?
        FileUtils.rm_rf(ENV['REPOSITORY_FILESTORE'])
      end
    end

    it 'redirects to the url of the binary payload' do
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end

    it 'checks to make sure that the file_set content is a PNG' do
      expect(file_set.files.first.content.read).to match(/PNG/)
    end
  end
end
