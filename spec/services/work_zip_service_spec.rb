# frozen_string_literal: true

require 'rails_helper'

describe WorkZipService do
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
        is_expected.to eq('tmp/my_work_is_empty.zip')
        expect(zip_file.entries.count).to eq(0)
      end
    end

    context 'An different location' do
      let(:service) { described_class.new(work, user, '/tmp') }
      let(:work) { build :work, title: ['My Work Is empty'], depositor: user.login }

      it 'creates a zip' do
        is_expected.to eq('/tmp/my_work_is_empty.zip')
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
        mp3_file
        work.ordered_members << my_file
        work.ordered_members << unreadble_file
        work.save
      end

      it 'creates a zip and filters the files we do not have access to read' do
        is_expected.to eq('tmp/my_work_is_great.zip')
        expect(zip_file.entries.map(&:name)).to contain_exactly(mp3_file.title.first, my_file.title.first)
        expect(zip_file.entries.map(&:size)).to contain_exactly(mp3_file.original_file.size, my_file.original_file.size)
      end
    end
  end
end
