# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

describe Scholarsphere::Pairtree do
  context 'fedora external content' do
    let(:user)     { create(:user) }
    let(:file_set) { create(:file_set, :with_png, depositor: user.login, id: 'mst3kabc') }
    let(:filepath) { File.join(fixture_path, 'world.png') }
    let(:bagger) { Scholarsphere::Bagger }
    let!(:pairtree) { described_class.new(file_set, bagger) }

    before do
      ENV['REPOSITORY_EXTERNAL_FILES'] = 'true'
      IngestFileJob.perform_now(file_set, filepath, user)
    end

    after do
      file_set.delete
      file_set.eradicate
      if Rails.env.test?
        FileUtils.rm_rf(ENV['REPOSITORY_FILESTORE'])
      end
    end

    it 'ensures the REPOSITORY_FILESTORE exists' do
      expect(Dir.exist?(ENV['REPOSITORY_FILESTORE'])).to eq true
    end

    it 'generates a pair tree string for a fileset' do
      expect(pairtree.path).to match /\/ms\/t3\/ka\/bc\/mst3kabc\/[0-9][0-9]*/
    end

    it 'ensures the file object directory exists' do
      expect(Dir.exist?(pairtree.full_path)).to eq true
    end

    it 'copies the object to the object directory' do
      expect(File.exist?(pairtree.full_path + '/' + File.basename(filepath))).to eq true
    end

    it 'returns the http path to the object' do
      expect(pairtree.http_path(filepath)).to eq(ENV['REPOSITORY_FILESTORE_HOST'] + pairtree.path + '/' + File.basename(filepath))
    end
  end
end
