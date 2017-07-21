# frozen_string_literal: true
require "rails_helper"

describe SolrDocument do
  let(:work) { build(:work, id: "foo") }
  subject { described_class.new(work.to_solr) }

  describe "#export_as_endnote" do
    let(:export) do
      "%0 Work\n" \
      "%T Sample Title\n" \
      "%R http://scholarsphere.psu.edu/files/#{work.id}\n" \
      "%~ ScholarSphere\n" \
      "%W Penn State"
    end
    its(:export_as_endnote) { is_expected.to eq(export) }
  end

  describe "#file_size" do
    subject { described_class.new(file_size_lts: ["1234"]) }
    its(:file_size) { is_expected.to eq("1234") }
  end

  describe "#bytes" do
    subject { described_class.new(bytes_lts: ["1234"]) }
    its(:bytes) { is_expected.to eq("1234") }
  end

  describe "#to_hash" do
    its(:to_hash) { is_expected.to eq(subject.to_h) }
  end
end
