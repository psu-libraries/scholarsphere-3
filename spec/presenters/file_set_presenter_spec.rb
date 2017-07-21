# frozen_string_literal: true
require "rails_helper"

describe FileSetPresenter do
  let(:file)          { build(:file_set) }
  let(:solr_document) { SolrDocument.new(file.to_solr) }
  let(:ability)       { double "Ability" }
  let(:presenter)     { described_class.new(solr_document, ability) }

  subject { presenter }

  describe "#related_files" do
    its(:related_files) { is_expected.to be_empty }
  end

  describe "#file_size" do
    before { allow(file).to receive(:file_size).and_return(["4906"]) }
    its(:file_size) { is_expected.to eq("4.79 KB") }
  end
end
