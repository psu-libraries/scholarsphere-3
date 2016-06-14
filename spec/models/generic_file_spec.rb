# frozen_string_literal: true
require 'spec_helper'

describe GenericFile, type: :model do
  let(:file) { create(:file) }

  subject { file }

  it "creates a noid on save" do
    expect(subject.id.length).to eq 9
  end

  describe "#export_as_endnote" do
    let(:export) do
      "%0 GenericFile\n" \
      "%T Sample Title\n" \
      "%R http://scholarsphere.psu.edu/files/#{file.id}\n" \
      "%~ ScholarSphere\n" \
      "%W Penn State University"
    end
    its(:export_as_endnote) { is_expected.to eq(export) }
  end

  describe "#create_thumbnail" do
    describe "with an image that doesn't get resized" do
      let(:file) { create(:file, :with_png) }
      before do
        allow(file).to receive(:mime_type) { 'image/png' } # Would get set by the characterization job
        allow(file).to receive(:width) { ['50'] } # Would get set by the characterization job
        allow(file).to receive(:height) { ['50'] } # Would get set by the characterization job
      end
      its(:content) { is_expected.not_to be_changed }
    end
  end

  describe "#characterize" do
    let(:file) { create(:file, :with_pdf, :characterized) }

    it "does NOT append metadata from the characterization" do
      expect(subject.title).not_to include "Microsoft Word - sample.pdf.docx"
      expect(subject.format_label).to eq ["Portable Document Format"]
    end
  end
end
