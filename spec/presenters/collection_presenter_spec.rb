# frozen_string_literal: true

require 'rails_helper'

describe CollectionPresenter do
  describe '#terms' do
    subject { described_class.terms }

    it { is_expected.to include(:creator, :keyword, :size, :total_items, :resource_type, :contributor,
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
end
