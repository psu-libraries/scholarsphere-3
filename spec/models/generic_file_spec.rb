# frozen_string_literal: true
require 'spec_helper'

describe GenericFile, type: :model do
  let(:file) do
    described_class.new(id: 'somepid') { |file| file.apply_depositor_metadata('dmc') }
  end

  it 'exports as endnote' do
    expect(file.export_as_endnote).to eq("%0 GenericFile\n%R http://scholarsphere.psu.edu/files/somepid\n%~ ScholarSphere\n%W Penn State University")
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
      subject { file }

      it "keeps the thumbnail at its original size" do
        expect(subject.content).not_to be_changed
      end
    end
  end

  describe "#characterize" do
    before do
      file.add_file(File.open(fixture_path + '/scholarsphere/scholarsphere_test4.pdf', 'rb'), path: 'content', original_name: 'sufia_test4.pdf')
      file.characterize
    end
    subject { file }

    it "does NOT append metadata from the characterization" do
      expect(subject.title).not_to include "Microsoft Word - sample.pdf.docx"
      expect(subject.format_label).to eq ["Portable Document Format"]
    end
  end

  describe "noid instead of id" do
    let(:file) { described_class.new { |f| f.apply_depositor_metadata('dmc') } }

    it "creates a noid on save" do
      file.save
      expect(file.id.length).to eq 9
    end
  end
end
