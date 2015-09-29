require 'spec_helper'

describe GenericFileListToCSVService do
  let (:service) { described_class.new(file_list) }
  let (:header) { "Url,Time Uploaded,Id,Title,Depositor,Creator,Visibility,Resource Type,Rights,File Format\n" }

  describe "#csv" do
    subject { service.csv }

    context "with no files" do
      let(:file_list) { [] }
      it { is_expected.to eq(header) }
    end

    context "with one files" do
      let(:file_list) { [GenericFile.new(id: 'abc123')] }
      it { is_expected.to include('files/abc123,"",abc123') }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 2
        expect(parsed[0]).to eq(["Url","Time Uploaded", "Id", "Title", "Depositor", "Creator", "Visibility", "Resource Type", "Rights", "File Format"])
        expect(parsed[1]).to include("abc123")
      end
    end

    context "with multiple files" do
      let(:file_list) { [GenericFile.new(id: 'abc123'), GenericFile.new(id: 'def456'), GenericFile.new(id: 'ghi789')] }
      it { is_expected.to include('files/abc123,"",abc123') }
      it { is_expected.to include('files/def456,"",def456') }
      it { is_expected.to include('files/ghi789,"",ghi789') }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 4
        expect(parsed[0]).to eq(["Url","Time Uploaded", "Id", "Title", "Depositor", "Creator", "Visibility", "Resource Type", "Rights", "File Format"])
        expect(parsed[1]).to include("abc123")
        expect(parsed[2]).to include("def456")
        expect(parsed[3]).to include("ghi789")
      end
    end
  end
end
