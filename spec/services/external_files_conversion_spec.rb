# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'
require 'digest'

describe ExternalFilesConversion do
  context 'running a conversion from internal to external file storage' do
    let(:full_conversion) { described_class.new(GenericWork).convert }
    let(:single_work_conversion) { described_class.new(GenericWork).convert(id: work.id) }
    let(:user) { create(:user) }
    let(:work) { create(:public_work_with_pdf, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:filepath) { File.join(fixture_path, 'test.pdf') }
    let(:fedora_sha1) { 'urn:sha1:ad13c5e7cc6d8198f25e003bd2965b3544e52a32' }
    let(:fedora_sha1_without_urn) { 'ad13c5e7cc6d8198f25e003bd2965b3544e52a32' }
    let(:empty_string_fedora_sha1) { 'urn:sha1:da39a3ee5e6b4b0d3255bfef95601890afd80709' }
    let(:sha1) { Digest::SHA1.new }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'converts all works of a given Class and has the correct checksums' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response.to_s).to match(/OK/)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      full_conversion
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/test.pdf/)
      expect(file_set.original_file.original_name).to eq('test.pdf')

      # Test the fixity service checksum
      fs = ActiveFedora::FixityService.new(file_set.files.first.uri)
      expect(fs.expected_message_digest).to eq(empty_string_fedora_sha1)

      # Check the checksum of the temp file
      latest_file_directory = Dir.entries(Rails.root.join('tmp', 'external_internal_conversion')).sort.last
      world_png = Rails.root.join('tmp', 'external_internal_conversion', latest_file_directory, 'test.pdf')
      world_png_file = File.read(world_png)
      expect(sha1.hexdigest(File.read(world_png_file))).to eq(fedora_sha1_without_urn)
      world_png_file.close

      # Check the checksum of the redirect repository file
      expect(sha1.hexdigest(open(response.uri).read)).to eq(fedora_sha1_without_urn)
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
      expect(response['content-disposition']).to match(/test.pdf/)
      expect(file_set.original_file.original_name).to eq('test.pdf')
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
        response = Net::HTTP.get_response(URI(file_set1.files.first.uri.to_s))
        expect(response.to_s).to match(/OK/)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        described_class.new(GenericWork).convert(file: pidfile)
        response = Net::HTTP.get_response(URI(file_set1.files.first.uri.to_s))
        expect(response['content-disposition']).to match(/test.pdf/)
        expect(file_set1.original_file.original_name).to eq('test.pdf')
        expect(response.to_s).to match(/HTTPTemporaryRedirect/)
      end
      it "adds any ids it can't convert to an error file" do
        converter = described_class.new(GenericWork)
        expect(converter.error_file).to match(/error/)
        work3_id = work3.id
        work3.delete
        converter.convert(file: pidfile)
        expect(File.readlines(converter.error_file).each(&:chomp!).first).to eq work3_id
      end
      it 'makes files with all the pids' do
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        FileUtils.rm_rf Rails.root.join('tmp', 'external_files_conversion')
        converter = described_class.new(GenericWork)
        expect(converter.pid_lists).to be_empty
        converter.convert(lists: true)
        expect(converter.pid_lists).not_to be_empty
        expect(File.exists?(converter.pid_lists.first)).to eq true
      end
      it 'will not convert an object if its files are already stored externally' do
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork)
        converter.convert(file: pidfile)
        expect(File.exist?(converter.error_file)).to eq false
        converter.convert(file: pidfile)
        # If it tried to convert the objects again, their PIDs would
        # be in the error file
        expect(File.exist?(converter.error_file)).to eq false
      end
    end
  end
end
