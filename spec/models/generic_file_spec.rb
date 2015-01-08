require 'spec_helper'

describe GenericFile, type: :model do

  let(:user) { FactoryGirl.create :random_user }
  let(:file) do
    file = GenericFile.new(id: 'somepid')
    file.apply_depositor_metadata(user.user_key)
    return file
  end

  it 'should export as endnote' do
    expect(file.export_as_endnote).to eq("%0 GenericFile\n%R http://scholarsphere.psu.edu/files/somepid\n%~ ScholarSphere\n%W Penn State University")
  end

  describe "#create_thumbnail" do
    describe "with an image that doesn't get resized" do
      subject do
        allow(file).to receive(:mime_type) { 'image/png' } # Would get set by the characterization job
        allow(file).to receive(:width) { ['50'] } # Would get set by the characterization job
        allow(file).to receive(:height) { ['50'] } # Would get set by the characterization job
        file.add_file_datastream(File.open("#{Rails.root}/spec/fixtures/world.png", 'rb'), dsid:'content')
        file.save
        return file
      end
      it "should keep the thumbnail at its original size" do
        expect(subject.content.changed?).to be_falsey
      end
    end
  end

  describe "#save" do
    it "should schedule a characterization job" do
      file.add_file_datastream(File.new(Rails.root + 'spec/fixtures/world.png'), dsid:'content')
      file.save
    end
  end

  describe "#characterize" do
    describe "after job runs" do
      subject do
        file.add_file(File.open(fixture_path + '/scholarsphere/scholarsphere_test4.pdf', 'rb').read, 'content', 'sufia_test4.pdf')
        file.characterize
        return file
      end
      it "should NOT append metadata from the characterization" do
        expect(subject.title).not_to include("Microsoft Word - sample.pdf.docx")
        expect(subject.filename[0]).to eq(subject.label)
        expect(subject.format_label).to eq(["Portable Document Format"])
      end
    end
  end

end
