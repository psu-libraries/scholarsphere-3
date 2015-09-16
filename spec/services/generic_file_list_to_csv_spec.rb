require 'spec_helper'

describe GenericFileListToCSVService do
  let (:service) { GenericFileListToCSVService.new(file_list) }
  let (:header) { "url,id,title,depositor,creator,visibility,resource_type,rights,file_format\n"}

  describe "#csv" do
    subject { service.csv }

    context "with no files" do
      let(:file_list) { [] }
      it { is_expected.to eq(header) }
    end

    context "with one files" do
      let(:file_list) { [GenericFile.new(id: 'abc123')] }
      it { is_expected.to include('files/abc123,abc123') }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 2
        expect(parsed[0]).to eq(["url", "id", "title", "depositor", "creator", "visibility", "resource_type", "rights", "file_format"])
        expect(parsed[1]).to include("abc123")
      end
    end

    context "with multiple files" do
      let(:file_list) { [GenericFile.new(id: 'abc123'), GenericFile.new(id: 'def456'), GenericFile.new(id: 'ghi789') ] }
      it { is_expected.to include('files/abc123,abc123') }
      it { is_expected.to include('files/def456,def456') }
      it { is_expected.to include('files/ghi789,ghi789') }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 4
        expect(parsed[0]).to eq(["url", "id", "title", "depositor", "creator", "visibility", "resource_type", "rights", "file_format"])
        expect(parsed[1]).to include("abc123")
        expect(parsed[2]).to include("def456")
        expect(parsed[3]).to include("ghi789")
      end
    end
  end
end
