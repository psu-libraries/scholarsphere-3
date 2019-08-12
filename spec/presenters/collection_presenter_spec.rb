# frozen_string_literal: true

require 'rails_helper'

describe CollectionPresenter do
  describe '#terms' do
    subject { described_class.terms }

    it { expect(subject).to include(:creator, :keyword, :size, :total_items, :resource_type, :contributor,
                                :rights, :publisher, :date_created, :subject, :language, :identifier,
                                :based_near, :related_url, :date_modified, :date_uploaded) }
  end

  describe '#size' do
    subject { CurationConcerns::CollectionPresenter.new(doc, nil) }

    let(:collection) { build(:public_collection) }
    let(:doc)        { SolrDocument.new(collection.to_solr) }

    before { allow(collection).to receive(:bytes).and_return('40') }

    its(:size) { is_expected.to eq('40 Bytes') }
  end

  describe '#zip_available?' do
    subject { presenter }

    let(:presenter) { described_class.new(doc, nil) }
    let(:collection) { build(:public_collection) }
    let(:doc) { SolrDocument.new(collection.to_solr.merge!(member_ids_ssim: member_ids, id: '1234')) }

    context 'when there are no member docs present' do
      let(:member_ids) { [] }

      it { is_expected.not_to be_zip_available }
    end

    context 'when the zip download path is present' do
      let(:member_ids) { ['1'] }

      before { allow(presenter).to receive(:zip_download_path).and_return('/path') }

      it { is_expected.to be_zip_available }
    end

    context 'when the zip download path is present' do
      let(:member_ids) { ['1'] }

      before { allow(presenter).to receive(:zip_download_path).and_return(nil) }

      it { is_expected.not_to be_zip_available }
    end
  end

  describe '#zip_download_path' do
    subject { presenter }

    let(:presenter) { described_class.new(doc, nil) }
    let(:collection) { build(:public_collection) }
    let(:doc) { SolrDocument.new(collection.to_solr.merge!(id: '1234', bytes_lts: bytes)) }

    context 'when the collection is smaller than the zip file size threshold' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold - 1_000 }

      its(:zip_download_path) { is_expected.to eq("/downloads/#{presenter.id}") }
    end

    context 'when the work is larger than the zip file size threshold but the zip does not exist' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 1_000 }

      its(:zip_download_path) { is_expected.to be_nil }
    end

    context 'when the work is larger than the zip file size threshold and the zip exists' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 1_000 }
      let(:zipfile) { ScholarSphere::Application.config.public_zipfile_directory.join("#{presenter.id}.zip") }

      before { FileUtils.touch(zipfile) }

      after  { FileUtils.rm_f(zipfile) }

      its(:zip_download_path) { is_expected.to eq("/zip-test/#{presenter.id}.zip") }
    end
  end
end
