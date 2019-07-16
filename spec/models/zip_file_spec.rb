# frozen_string_literal: true

require 'rails_helper'

describe ZipFile do
  subject { described_class.new(file) }

  let(:id) { SecureRandom.uuid }
  let(:file) { ScholarSphere::Application.config.public_zipfile_directory.join("#{id}.zip") }

  describe '#delete' do
    before { FileUtils.touch(file) }

    it 'removes the file' do
      expect(file).to be_exist
      described_class.new(file).delete
      expect(file).not_to be_exist
    end
  end

  describe '#exist?' do
    before { FileUtils.touch(file) }

    it { is_expected.to be_exist }
  end

  describe '#parent' do
    before { FileUtils.touch(file) }

    its(:parent) { is_expected.to eq(ScholarSphere::Application.config.public_zipfile_directory) }
  end

  describe '#basename' do
    before { FileUtils.touch(file) }

    its(:basename) { is_expected.to eq(Pathname.new("#{id}.zip")) }
  end

  describe '#exceeds_threshold?' do
    context "when the resource's size still exceeds the threshold" do
      before do
        index_document(build(:public_work, id: id).to_solr.merge!(bytes_lts: 600_000_000))
      end

      it { is_expected.to be_exceeds_threshold }
    end

    context "when the resource's size no longer exceeds the threshold" do
      before do
        index_document(build(:public_work, id: id).to_solr.merge!(bytes_lts: 600_000))
      end

      it { is_expected.not_to be_exceeds_threshold }
    end

    context 'when the resource does not exist' do
      it { is_expected.not_to be_exceeds_threshold }
    end
  end

  describe '#stale?' do
    context 'when the resource is newer than the file' do
      before do
        FileUtils.touch(file, mtime: (DateTime.now - 2.days).to_i)
        index_document(build(:public_work, id: id).to_solr)
      end

      it { is_expected.to be_stale }
    end

    context 'when the resource is older than the file' do
      before do
        FileUtils.touch(file, mtime: (DateTime.now + 2.days).to_i)
        index_document(build(:public_work, id: id).to_solr)
      end

      it { is_expected.not_to be_stale }
    end

    context 'when the resource does not exist' do
      it { is_expected.to be_stale }
    end
  end
end
