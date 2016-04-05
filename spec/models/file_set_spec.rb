# frozen_string_literal: true
require 'spec_helper'

describe FileSet, type: :model do
  let(:file) { build(:file_set, :with_png, label: "sample_png") }

  subject { file }

  describe "::indexer" do
    subject { described_class.indexer }
    it { is_expected.to be(CurationConcerns::FileSetIndexer) }
  end

  describe "#.to_solr" do
    subject { file.to_solr }
    it { is_expected.to include(Solrizer.solr_name("file_format") => "png") }
    it { is_expected.to include(Solrizer.solr_name("label") => "sample_png") }
  end

  describe "#file_format" do
    it "is deprecated" do
      expect(Deprecation).to receive(:warn)
      expect(subject.file_format).to eq("png")
    end
  end

  describe "#visibility" do
    context "by default" do
      its(:visibility) { is_expected.to eq("restricted") }
      its(:public?) { is_expected.to be false }
      its(:registered?) { is_expected.to be false }
    end
  end

  describe "#time_uploaded" do
    context "with a blank date_uploaded" do
      its(:time_uploaded) { is_expected.to be_blank }
    end
    context "with date_uploaded" do
      let(:file) { build(:file_set, date_uploaded: Date.today) }
      its(:time_uploaded) { is_expected.to eq(Date.today.strftime("%Y-%m-%d %H:%M:%S")) }
    end
  end

  describe "#url" do
    let(:url) { Rails.application.routes.url_helpers.curation_concerns_file_set_path(file) }
    its(:url) { is_expected.to end_with(url) }
  end

  describe "#create_thumbnail" do
    describe "with an image that doesn't get resized" do
      before do
        allow(file).to receive(:mime_type) { 'image/png' } # Would get set by the characterization job
        allow(file).to receive(:width) { ['50'] } # Would get set by the characterization job
        allow(file).to receive(:height) { ['50'] } # Would get set by the characterization job
      end
      its(:content) do
        skip "Is this still relevant?"
        is_expected.not_to be_changed
      end
    end
  end

  describe "#characterize" do
    let(:file) { create(:file, :with_pdf, :characterized) }

    it "does NOT append metadata from the characterization" do
      skip "I think this is sufficiently handled in Hydra::Works::CharacterizationService"
      expect(subject.title).not_to include "Microsoft Word - sample.pdf.docx"
      expect(subject.format_label).to eq ["Portable Document Format"]
    end
  end
end
