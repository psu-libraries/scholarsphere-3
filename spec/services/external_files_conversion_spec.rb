# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe ExternalFilesConversion do
  let(:user) { create(:user) }

  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end

  context 'running a conversion from internal to external file storage' do
    let(:full_conversion) { described_class.new(GenericWork).convert }
    let(:single_work_conversion) { described_class.new(GenericWork).convert(id: work.id) }
    let(:work) { create(:public_work_with_png, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:filepath) { File.join(fixture_path, 'world.png') }
    let(:mock_checksum) { instance_double(Digest::SHA1, hexdigest: 'f794b23c0c6fe1083d0ca8b58261a078cd968967') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
      allow(Digest::SHA1).to receive(:file).and_return(mock_checksum)
    end

    after do
      work.destroy
    end

    it 'converts a single work of a given Class' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      local_file(file_set.files.first.uri.to_s)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      single_work_conversion
      response = Net::HTTP.get_response(URI(file_set.files.first.uri.to_s))
      expect(response['content-disposition']).to match(/world.png/)
      expect(file_set.original_file.original_name).to eq('world.png')
      expect(response.to_s).to match(/HTTPTemporaryRedirect/)

      # does not error if you try to convert the file another time
      converter = described_class.new(GenericWork)
      converter.convert(id: work.id)
      expect(File.exist?(converter.error_file)).to eq false
    end
    it 'converts all works of a given Class' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      local_file(file_set.files.first.uri.to_s)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      full_conversion
      remote_file(file_set.files.first.uri.to_s)
    end
    it 'will not raise an error if it already has an auto_placeholder version' do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      file_set
      local_file(file_set.files.first.uri.to_s)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      ActiveFedora.fedora.connection.post(file_set.files.first.uri + '/fcr:versions', nil, slug: 'auto_placeholder')
      single_work_conversion
      remote_file(file_set.files.first.uri.to_s)
    end
    context 'bad checksums' do
      let(:mock_checksum) { instance_double(Digest::SHA1, hexdigest: 'f794b23c0c6fe1083d0ca8b58261a078cd96800') }

      it 'converts a single work of a given Class' do
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        file_set
        local_file(file_set.files.first.uri.to_s)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork)
        converter.convert(id: work.id)
        remote_file(file_set.files.first.uri.to_s)
        expect(File.readlines(converter.error_file).each(&:chomp!).first).to eq work.id
      end
    end
    context 'with three works' do
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

      after do
        # destroy could fail since some tests are destroying it
        begin
          work1.destroy
          work2.destroy
          work3.destroy
        rescue StandardError
          nil
        end
      end

      it 'converts the ids in a file' do
        local_file(file_set.files.first.uri.to_s)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork)
        expect(converter.error_file).to match(/error/)
        work3_id = work3.id
        work3.destroy

        converter.convert(file: pidfile)

        remote_file(file_set1.files.first.uri.to_s)
        remote_file(file_set2.files.first.uri.to_s)

        # it adds any ids it can't convert to an error file
        expect(File.readlines(converter.error_file).each(&:chomp!).first).to eq work3_id
      end
      it 'makes files with all the pids' do
        FileUtils.rm_rf Rails.root.join('tmp', 'external_files_conversion')
        converter = described_class.new(GenericWork)
        expect(converter.pid_lists).to be_empty
        converter.convert(lists: true)
        expect(converter.pid_lists).not_to be_empty
        converter.pid_lists.each do |file|
          expect(File.exists?(file)).to eq true
        end
        expect(File.readlines(converter.pid_lists.first).each(&:chomp!)).to contain_exactly work1.id, work2.id, work3.id
      end
      it 'makes a pid file with all the small objects and large files also get converted' do
        FileUtils.rm_rf Rails.root.join('tmp', 'external_files_conversion')
        allow(work1).to receive(:bytes).and_return(4.kilobytes)
        work1.update_index
        converter = described_class.new(GenericWork, 1.kilobyte)
        expect(converter.pid_lists).to be_empty
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter.convert
        expect(converter.pid_lists).not_to be_empty
        converter.pid_lists.each do |file|
          expect(File.exists?(file)).to eq true
        end
        expect(File.readlines(converter.pid_lists.first).each(&:chomp!)).to contain_exactly work2.id, work3.id

        expect(File.exists?(converter.error_file)).to eq false
        remote_file(file_set1.files.first.uri.to_s)
        remote_file(file_set2.files.first.uri.to_s)
        remote_file(file_set3.files.first.uri.to_s)
      end
    end
  end

  context 'bad digest for some time' do
    let(:work) { create(:public_work_with_png, depositor: user.login) }
    let(:file_set) { work.file_sets.first }
    let(:mock_fixity) { instance_double(ActiveFedora::FixityService) }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
      allow(ActiveFedora::FixityService).to receive(:new).and_return(mock_fixity)
    end

    context 'error with fixity once' do
      before do
        allow(CharacterizeJob).to receive(:perform_later)
        allow(ActiveFedora::FixityService).to receive(:new).and_return(mock_fixity)
      end

      it 'converts a single work of a given Class' do
        expect(mock_fixity).to receive(:expected_message_digest).once.and_raise(StandardError.new('bad stuff'))
        expect(mock_fixity).to receive(:expected_message_digest).once.and_return('urn:sha1:f794b23c0c6fe1083d0ca8b58261a078cd968967')
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        file_set
        local_file(file_set.files.first.uri.to_s)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork, 3.gigabytes, 0.001.seconds)
        converter.convert(id: work.id)
        remote_file(file_set.files.first.uri.to_s)

        expect(File).not_to be_exists(converter.error_file)
        remote_file(file_set.files.first.uri.to_s)
      end
    end

    context 'error with fixity 4 times' do
      it 'converts a single work of a given Class' do
        expect(mock_fixity).to receive(:expected_message_digest).exactly(4).times.and_raise(StandardError.new('bad stuff'))
        expect(mock_fixity).to receive(:expected_message_digest).once.and_return('urn:sha1:f794b23c0c6fe1083d0ca8b58261a078cd968967')
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        file_set
        local_file(file_set.files.first.uri.to_s)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork, 3.gigabytes, 0.001.seconds)
        converter.convert(id: work.id)

        expect(File).not_to be_exists(converter.error_file)
        remote_file(file_set.files.first.uri.to_s)
      end
    end

    context 'error with fixity 5 times' do
      it 'converts a single work of a given Class' do
        expect(mock_fixity).to receive(:expected_message_digest).exactly(5).times.and_raise(StandardError.new('bad stuff'))
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
        file_set
        local_file(file_set.files.first.uri.to_s)
        ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
        converter = described_class.new(GenericWork, 3.gigabytes, 0.001.seconds)
        converter.convert(id: work.id)

        expect(File.readlines(converter.error_file).each(&:chomp!).first).to eq work.id
        local_file(file_set.files.first.uri.to_s)
      end
    end
  end
  context 'running without sha1 mocked', unless: travis? do
    it 'converts all versions of all the files of a work' do
      allow(Digest::SHA1).to receive(:file).and_call_original
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'false'
      work_with_versions = create(:public_work_with_lots_of_versions, depositor: user.login)
      work_with_versions.reload
      expect(work_with_versions.file_sets.first.files).not_to be_blank
      CharacterizeJob.perform_now(work_with_versions.file_sets[2], 'blah', File.join(fixture_path, 'test.pdf'))
      local_file(work_with_versions.file_sets.first.files.first.uri.to_s)
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      converter = described_class.new(GenericWork)
      converter.convert(id: work_with_versions.id)
      expect(File).not_to be_exists(converter.error_file)
      work_with_versions.file_sets.each do |file_set|
        file_set.files.each do |file|
          file.versions.all.each do |version|
            remote_file(version.uri.to_s)
          end
        end
      end
    end
  end

  def local_file(uri)
    ldp_response = ActiveFedora.fedora.connection.head(uri)
    expect(ldp_response.response.status).to eq(200)
  end

  def remote_file(uri)
    ldp_response = ActiveFedora.fedora.connection.head(uri)
    expect(ldp_response.response.status).to eq(307), "version: #{uri} was not converted to external"
  end
end
