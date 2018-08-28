# frozen_string_literal: true

require 'rails_helper'

describe ExternalFilesConversion do
  context 'running a conversion from internal to external file storage' do
    let(:full_conversion) { described_class.new(GenericWork).convert }
    let(:single_work_conversion) { described_class.new(GenericWork).convert(id: work.id) }
    let(:user) { create(:user) }
    let(:work) { create(:public_work_with_png, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:filepath) { File.join(fixture_path, 'world.png') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'converts all works of a given Class' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/OK/)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      full_conversion
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end
    it 'converts a single work of a given Class' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/OK/)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      single_work_conversion
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)
    end
    context 'running from a file' do
      let(:work1) { create(:public_work_with_png, depositor: user.login) }
      let(:file_set1) { work1.file_sets.first }

      let(:work2) { create(:public_work_with_png, depositor: user.login) }
      let(:file_set2) { work2.file_sets.first }

      let(:work3) { create(:public_work_with_png, depositor: user.login) }
      let(:file_set3) { work3.file_sets.first }

      let(:pidfile) { File.join(Rails.root, 'tmp', 'pidfile.txt') }

      before do
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        File.delete(pidfile) if File.exists?(pidfile)
        File.open(pidfile, 'w') { |file|
          file.puts work1.id
          file.puts work2.id
          file.puts work3.id
        }
      end

      it 'converts the ids in a file' do
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        file_set1
        file_set2
        file_set3
        response = Net::HTTP.get_response(URI(file_set1.files.first.uri.to_s))
        expect(response.to_s).to match(/OK/)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        described_class.new(GenericWork).convert(file: pidfile)
        response = Net::HTTP.get_response(URI(file_set1.files.first.uri.to_s))
        expect(response['content-disposition']).to match(/world.png/)
        expect(file_set1.original_file.original_name).to eq('world.png')
        expect(response.to_s).to match(/HTTPTemporaryRedirect/)
      end
    end
  end
end
