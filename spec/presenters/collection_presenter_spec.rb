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
    subject(:presenter) { described_class.new(doc, nil) }

    let(:collection) { build(:public_collection) }

    let(:doc) do
      SolrDocument.new(collection.to_solr.merge!(
                         bytes_lts: bytes,
                         member_ids_ssim: member_ids,
                         id: '1234'
                       ))
    end

    context 'when there are no member docs present' do
      let(:bytes) { 0 }
      let(:member_ids) { [] }

      it { is_expected.not_to be_zip_available }
    end

    context 'when the collection is smaller than the zip file size threshold' do
      let(:bytes) { 10 }
      let(:member_ids) { ['1', '2'] }

      it { is_expected.to be_zip_available }
    end

    context 'when the collection is larger than the zip file size threshold and the file is present' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 100 }
      let(:member_ids) { ['1', '2'] }

      before { FileUtils.touch(ScholarSphere::Application.config.public_zipfile_directory.join("#{doc.id}.zip")) }

      after { FileUtils.rm_f(ScholarSphere::Application.config.public_zipfile_directory.join("#{doc.id}.zip")) }

      it { is_expected.to be_zip_available }
    end

    context 'when the collection is larger than the zip file size threshold and the file is not present' do
      let(:bytes) { ScholarSphere::Application.config.zipfile_size_threshold + 100 }
      let(:member_ids) { ['1', '2'] }

      it { is_expected.not_to be_zip_available }
    end
  end
end
