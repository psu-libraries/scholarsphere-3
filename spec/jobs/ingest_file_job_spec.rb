# frozen_string_literal: true

require 'rails_helper'

describe IngestFileJob do
  context 'when adding a new version' do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login) }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it "updates the file set's title with the file name" do
      expect(file_set.title).to contain_exactly('Sample PNG')
      described_class.perform_now(file_set, filepath, user)
      expect(file_set.title).to contain_exactly('world.png')
    end
  end

  context 'fedora external content' do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login, id: 'mst3kabc') }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      allow(CharacterizeJob).to receive(:perform_later)
      described_class.perform_now(file_set, filepath, user)
    end
    after do
      file_set.delete
      file_set.eradicate
    end
    it 'ensures the REPOSITORY_FILESTORE exists' do
      expect(Dir.exist?(ENV['REPOSITORY_FILESTORE'])).to eq true
    end

    it 'generates a pair tree string for a fileset' do
      expect(described_class.pairtree_path(file_set)).to eq '/ms/t3/ka/bc/mst3kabc'
    end

    it 'returns the full path to the object' do
      expect(described_class.object_path(file_set)).to eq ENV['REPOSITORY_FILESTORE'] + described_class.pairtree_path(file_set)
    end

    it 'ensures the file object directory exists' do
      expect(Dir.exist?(ENV['REPOSITORY_FILESTORE'] + described_class.pairtree_path(file_set))).to eq true
    end

    it 'copies the object to the object directory' do
      expect(File.exist?(ENV['REPOSITORY_FILESTORE'] + described_class.pairtree_path(file_set) + '/' + File.basename(filepath))).to eq true
    end

    it 'returns the http path to the object' do
      expect(described_class.pairtree_http_path(file_set, filepath)).to eq(ENV['REPOSITORY_FILESTORE_HOST'] + described_class.pairtree_path(file_set) + '/' + File.basename(filepath))
    end

    it 'redirects to the url of the binary payload' do
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end

    it 'is a pending example that checks to make sure that the file_set content is not blank' do
      expect(file_set.files.first.content).to match(/PNG/)
    end
  end
end
