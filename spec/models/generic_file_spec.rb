# frozen_string_literal: true
require 'spec_helper'

describe GenericFile, type: :model do
  let(:file) do
    described_class.create.tap do |file|
      file.apply_depositor_metadata('dmc')
      file.save
    end
  end

  subject { file }

  it "creates a noid on save" do
    expect(subject.id.length).to eq 9
  end

  describe "#export_as_endnote" do
    let(:export) { "%0 GenericFile\n%R http://scholarsphere.psu.edu/files/somepid\n%~ ScholarSphere\n%W Penn State University" }
    subject { described_class.new(id: 'somepid') { |file| file.apply_depositor_metadata('dmc') } }
    its(:export_as_endnote) { is_expected.to eq(export) }
  end

  describe "#create_thumbnail" do
    describe "with an image that doesn't get resized" do
      before do
        allow(file).to receive(:mime_type) { 'image/png' } # Would get set by the characterization job
        allow(file).to receive(:width) { ['50'] } # Would get set by the characterization job
        allow(file).to receive(:height) { ['50'] } # Would get set by the characterization job
        file.add_file(File.open("#{Rails.root}/spec/fixtures/world.png", 'rb'), path: 'content')
        file.save
      end
      its(:content) { is_expected.not_to be_changed }
    end
  end

  describe "#characterize" do
    before do
      file.add_file(File.open(fixture_path + '/scholarsphere/scholarsphere_test4.pdf', 'rb'), path: 'content', original_name: 'sufia_test4.pdf')
      file.characterize
    end

    it "does NOT append metadata from the characterization" do
      expect(subject.title).not_to include "Microsoft Word - sample.pdf.docx"
      expect(subject.format_label).to eq ["Portable Document Format"]
    end
  end
end
