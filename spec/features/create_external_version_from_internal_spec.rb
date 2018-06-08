# frozen_string_literal: true

# Testing versioning as a strategy for migrating from internal to externally
# managed Fedora content

require 'rails_helper'

describe 'transform internal file storage into external file storage' do
  context 'when adding a new version' do
    let(:user) { create(:user) }
    let(:work) { create(:public_work_with_png, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'can create an external version from an initially interal object' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/OK/)

      # Create a version with external files set to true
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      IngestFileJob.perform_now(file_set, filepath, user, filename: 'world.png')
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)

      # Create a version of a work that was versioned with external files
      IngestFileJob.perform_now(file_set, filepath, user)
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end
  end
end
