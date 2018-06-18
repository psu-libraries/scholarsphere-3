# frozen_string_literal: true

# Testing versioning as a strategy for migrating from internal to externally
# managed Fedora content

require 'rails_helper'

describe 'transform internal file storage into external file storage', clean: true do
  context 'when adding a new version' do
    let(:user) { create(:user) }
    let(:filepath) { File.join(fixture_path, 'world.png') }
    let(:filepath2) { File.join(fixture_path, '4-20-small.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'can create an external version from an initially interal object' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'

      # Create an initial work without external files
      work = create(:public_work_with_lots_of_versions, depositor: user.login)

      work.ordered_members.to_a.each do |file_set|
        file_set.files.each do |file|
          file.versions.all.each do |version|
            # Test that the file is not a redirect
            response = Net::HTTP.get_response(URI(version.uri.to_s))
            expect(response.to_s).to match(/OK/)
          end
        end
      end

      expect(work.file_sets.first.files.first.versions.all.size).to eq(2)

      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'

      ExternalFilesConversion.new(GenericWork).convert

      work.reload

      work.ordered_members.to_a.each do |file_set|
        file_set.files.each do |file|
          file.versions.all.each do |version|
            # Test that the file is not a redirect
            response = Net::HTTP.get_response(URI(version.uri.to_s))
            expect(response.to_s).to match(/Redirect/)
          end
        end
      end

      # check to see that there are two versions, and that they have the correct name
      expect(work.ordered_members.to_a.first.files.first.versions.all.size).to eq(2)
      expect(work.ordered_members.to_a.first.files.first.versions.all.map(&:label)).to eq(['version1', 'version2'])
    end
  end
end
