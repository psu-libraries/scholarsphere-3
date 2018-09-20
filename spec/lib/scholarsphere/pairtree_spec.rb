# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe Scholarsphere::Pairtree do
  context 'fedora external content' do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login, id: 'mst3kabc') }
    let(:fixture_filepath) { File.join(fixture_path, 'world.png') }
    let(:crazy_filepath) { Rails.root.join('tmp', 'file with space %.png').to_s }
    let(:filepath) { 'file_with_space__.png' }
    let(:file_to_store) {}
    let(:bagger) { Scholarsphere::Bagger }
    let!(:pairtree) { described_class.new(file_set, bagger) }

    before do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      FileUtils.cp(fixture_filepath, crazy_filepath)
    end

    after do
      file_set.delete
      file_set.eradicate
      if Rails.env.test?
        FileUtils.rm_rf(ENV['REPOSITORY_FILESTORE'])
      end
      File.delete(crazy_filepath)
    end

    context 'done inside IngestFileJob' do
      before do
        IngestFileJob.perform_now(file_set, crazy_filepath, user)
      end

      it 'creates a bag under the paritree' do
        # ensures the REPOSITORY_FILESTORE exists
        expect(Dir.exist?(ENV['REPOSITORY_FILESTORE'])).to eq true

        # generates a pair tree string for a fileset
        expect(pairtree.path).to match /\/ms\/t3\/ka\/bc\/mst3kabc\/[0-9][0-9]*/

        # ensures the file object directory exists
        expect(Dir.exist?(pairtree.full_path)).to eq true

        # copies the object to the object directory
        expect(File.exist?(pairtree.full_path + '/' + filepath)).to eq true

        # bag file file matches the original
        expect(FileUtils.compare_file(pairtree.full_path + '/' + filepath, crazy_filepath)).to eq true

        # returns the http path to the object
        expect(pairtree.http_path(pairtree.full_path + '/' + filepath)).to eq(ENV['REPOSITORY_FILESTORE_HOST'] + pairtree.path + '/' + filepath)
      end
    end

    context 'done as stream' do
      let(:filepath) { File.join(fixture_path, 'little_file.txt') }

      before do
        pairtree.create_repository_files_from_string(File.open(filepath).read, File.basename(filepath))
      end

      it 'creates a bag under the paritree' do
        # ensures the REPOSITORY_FILESTORE exists
        expect(Dir.exist?(ENV['REPOSITORY_FILESTORE'])).to eq true

        # generates a pair tree string for a fileset
        expect(pairtree.path).to match /\/ms\/t3\/ka\/bc\/mst3kabc\/[0-9][0-9]*/

        # ensures the file object directory exists
        expect(Dir.exist?(pairtree.full_path)).to eq true

        # copies the object to the object directory
        expect(File.exist?(pairtree.full_path + '/' + File.basename(filepath))).to eq true

        # bag file file matches the original
        expect(FileUtils.compare_file(pairtree.full_path + '/' + File.basename(filepath), filepath)).to eq true

        # returns the http path to the object
        expect(pairtree.http_path(filepath)).to eq(ENV['REPOSITORY_FILESTORE_HOST'] + pairtree.path + '/' + File.basename(filepath))
      end
    end
  end
end
