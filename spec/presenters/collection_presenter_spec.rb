# frozen_string_literal: true
require "rails_helper"

describe CollectionPresenter do
  describe "#terms" do
    subject { described_class.terms }
    it { is_expected.to include(:date_modified, :date_uploaded) }
  end

  describe "#size" do
    let(:collection) { build(:public_collection) }
    let(:doc)        { SolrDocument.new(collection.to_solr) }
    before { allow(collection).to receive(:bytes).and_return("40") }
    subject { CurationConcerns::CollectionPresenter.new(doc, nil) }
    its(:size) { is_expected.to eq("40 Bytes") }
  end
end
