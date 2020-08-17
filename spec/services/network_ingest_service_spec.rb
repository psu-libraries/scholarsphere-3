# frozen_string_literal: true

require 'rails_helper'

describe NetworkIngestService do
  describe '::call' do
    context 'with an existing empty work and new files' do
      let(:user) { create(:user) }
      let(:reader) { create(:user) }
      let(:work) { create(:work, depositor: user.login, read_users: [reader.login]) }
      let(:path) { Pathname.new(ScholarSphere::Application.config.network_ingest_directory).join(work.id) }

      before do
        FileUtils.mkdir(path)
        FileUtils.cp(Pathname.new(fixture_path).join('readme.md'), path)
        FileUtils.cp(Pathname.new(fixture_path).join('world.png'), path)
      end

      it 'ingests each file in the directory' do
        expect(work.file_sets).to be_empty
        edit_users = work.edit_users
        read_users = work.read_users
        described_class.call(path)
        work.reload
        expect(work.file_sets.count).to eq(2)
        expect(work.file_sets.map(&:title)).to include(['readme.md'], ['world.png'])
        work.file_sets.each do |file_set|
          expect(file_set.edit_users).to eq(edit_users)
          expect(file_set.read_users).to eq(read_users)
        end
      end
    end

    context 'when the work does not exist' do
      let(:path) { Pathname.new(ScholarSphere::Application.config.network_ingest_directory).join('badwork') }

      before do
        FileUtils.mkdir(path)
        FileUtils.cp(Pathname.new(fixture_path).join('readme.md'), path)
        FileUtils.cp(Pathname.new(fixture_path).join('world.png'), path)
      end

      it 'raises an error' do
        expect { described_class.call(path) }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end
