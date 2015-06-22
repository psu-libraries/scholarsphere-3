require 'spec_helper'

describe Collection do
  
  describe "#bytes" do
    context "with no attached files" do
      subject { Collection.create(title: "My collection") { |c| c.apply_depositor_metadata("agw") }.bytes }
      it { is_expected.to eq 0 }
    end

    context "with attached files" do
      let(:file) do
        GenericFile.create(title: ['Some title']) { |f| f.apply_depositor_metadata("agw") }
      end
      let(:file2) do
        GenericFile.create(title: ['Some other title']) { |f| f.apply_depositor_metadata("agw") }
      end
      let(:collection) do
        Collection.create(title: "My collection") { |c| c.apply_depositor_metadata("agw") }
      end
      let(:mock_file) { double("content", size: "100")}
      before do
        allow(mock_file).to receive(:changed?).and_return(false)
        allow_any_instance_of(GenericFile).to receive(:content).and_return(mock_file)
        collection.members = [file, file2]
        collection.save
      end
      subject { collection.bytes }
      it { is_expected.to eq 200 }
    end
  
  end
end
