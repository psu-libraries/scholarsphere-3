# frozen_string_literal: true
require "rails_helper"

describe WorkIndexer do
  include FactoryHelpers

  let(:file_set) { build(:file_set) }
  let(:work)     { build(:work, representative: file_set,
                                creator: ["BIG. Name"],
                                keyword: ["Bird"]) }
  let(:indexer)  { described_class.new(work) }

  let(:file) do
    mock_file_factory(
      mime_type: "image/jpeg",
      format_label: ["JPEG Image"],
      height: ["500"],
      width: ["600"],
      file_size: ["12"]
    )
  end

  describe "#generate_solr_document" do
    let(:solr_doc) { indexer.generate_solr_document }

    subject { solr_doc }
    it { is_expected.to include("bytes_lts" => 0) }

    describe "file_format" do
      subject { solr_doc[Solrizer.solr_name("file_format", :facetable)] }

      context "with a file containing technical metadata" do
        before { allow(file_set).to receive(:original_file).and_return(file) }
        it { is_expected.to eq("jpeg (JPEG Image)") }
      end

      context "without a file" do
        it { is_expected.to be_nil }
      end

      context "without a representative" do
        before { allow(work).to receive(:representative).and_return(nil) }
        it { is_expected.to be_nil }
      end
    end

    describe "a groomed document" do
      it { is_expected.to include("creator_sim" => ["Big Name"]) }
      it { is_expected.to include("creator_tesim" => ["BIG. Name"]) }
      it { is_expected.to include("keyword_sim" => ["bird"]) }
      it { is_expected.to include("keyword_tesim" => ["Bird"]) }
    end
  end
end
