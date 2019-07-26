# frozen_string_literal: true

require 'rails_helper'

describe WorkZipService do
  before do
    allow(CharacterizeJob).to receive(:perform_later)
  end

  describe '#call' do
    subject(:zip_file_name) { service.call }

    let(:service) { described_class.new(work, user) }
    let(:zip_file) { ::Zip::File.new(zip_file_name) }
    let(:user) { create(:user) }

    after do
      File.delete(zip_file_name)
    end

    context 'An empty work' do
      let(:work) { build :work, title: ['My Work Is empty'], depositor: user.login }

      it 'creates a zip' do
        expect(subject).to eq('tmp/my_work_is_empty.zip')
        expect(zip_file.entries.count).to eq(0)
      end
    end

    context 'A different location' do
      let(:service) { described_class.new(work, user, '/tmp') }
      let(:work) { build :work, title: ['My Work Is empty'], depositor: user.login }

      it 'creates a zip' do
        expect(subject).to eq('/tmp/my_work_is_empty.zip')
        expect(zip_file.entries.count).to eq(0)
      end
    end

    context 'A different zip file title' do
      let(:service) { described_class.new(work, user, '/tmp', "#{work.id}.zip") }
      let(:work) { build :work, title: ['Custom zip name'], depositor: user.login, id: SecureRandom.uuid }

      it 'creates a zip' do
        expect(subject).to eq("/tmp/#{work.id}.zip")
        expect(zip_file.entries.count).to eq(0)
      end
    end

    context 'A work with multiple file_sets' do
      let(:work) { create :public_work_with_mp3, title: ['My Work Is Great'], depositor: user.login }
      let(:mp3_file) { work.file_sets[0] }
      let(:file) { File.open(File.join(fixture_path, 'world.png')) }
      let(:file2) { File.open(File.join(fixture_path, 'small_file.txt')) }
      let(:my_file) { create(:file_set, user: user, content: file, title: ['world.png']) }
      let(:unreadble_file) { create(:file_set, user: user2, content: file2, title: ['small_file.txt']) }
      let(:user2) { create(:user) }

      before do
        work.ordered_members << my_file
        work.ordered_members << unreadble_file
        work.save
      end

      it 'creates a zip and filters the files we do not have access to read' do
        expect(subject).to eq('tmp/my_work_is_great.zip')
        expect(zip_file.entries.map(&:name)).to contain_exactly(mp3_file.title.first, my_file.title.first)
        expect(zip_file.entries.map(&:size)).to contain_exactly(mp3_file.original_file.size, my_file.original_file.size)
      end
    end

    context 'A newer zip file already exists' do
      let(:public_zip_file) { ScholarSphere::Application.config.public_zipfile_directory.join("#{work.id}.zip") }
      let(:work) { create :work, title: ['Pre-existing zip file'], depositor: user.login, id: SecureRandom.uuid }

      let(:service) do
        described_class.new(
          work,
          user,
          ScholarSphere::Application.config.public_zipfile_directory,
          "#{work.id}.zip"
        )
      end

      before { FileUtils.touch(public_zip_file, mtime: (DateTime.now + 2.days).to_i) }

      it 'does not re-create the zip file' do
        expect(Zip::File).not_to receive(:open)
      end
    end
  end
end
