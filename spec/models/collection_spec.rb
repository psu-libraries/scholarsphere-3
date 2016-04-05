# frozen_string_literal: true
require 'spec_helper'

describe Collection do
  describe "#bytes" do
    subject { collection.bytes }
    context "with no attached files" do
      let(:collection) { build(:collection) }
      it { is_expected.to eq 0 }
    end

    context "with attached files" do
      let(:mock_file)  { double("content", size: "100") }
      let(:file1)      { build(:file) }
      let(:file2)      { build(:file) }
      let(:collection) { create(:collection, members: [file1, file2]) }
      before do
        allow(mock_file).to receive(:changed?).and_return(false)
        allow(file1).to receive(:content).and_return(mock_file)
        allow(file2).to receive(:content).and_return(mock_file)
      end
      it { is_expected.to eq 200 }
    end
  end
end
