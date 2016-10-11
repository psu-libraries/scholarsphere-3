# frozen_string_literal: true
require 'rails_helper'

describe GenericWorkListToCSVService do
  let(:service) { described_class.new(file_list) }
  let(:header) { "Url,Time Uploaded,Id,Title,Depositor,Creator,Visibility,Resource Type,Rights,File Format\n" }

  describe "#csv" do
    subject { service.csv }

    context "with no files" do
      let(:file_list) { [] }
      it { is_expected.to eq(header) }
    end

    context "with one file" do
      let(:file_list) { [create(:work, :with_one_file, file_title: ["CSV Report 1"])] }
      it { is_expected.to include("CSV Report 1") }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 2
        expect(parsed[0]).to eq(["Url", "Time Uploaded", "Id", "Title", "Depositor", "Creator", "Visibility", "Resource Type", "Rights", "File Format"])
        expect(parsed[1]).to include("CSV Report 1")
      end
    end

    context "with multiple files" do
      let(:file_list) do
        [
          create(:work, :with_one_file, file_title: ["CSV Multifile-Report 1"]),
          create(:work, :with_one_file, file_title: ["CSV Multifile-Report 2"]),
          create(:work, :with_one_file, file_title: ["CSV Multifile-Report 3"])
        ]
      end
      it { is_expected.to include("CSV Multifile-Report 1", "CSV Multifile-Report 2", "CSV Multifile-Report 3") }
      it "can be parsed" do
        parsed = CSV.parse(subject)
        expect(parsed.count).to eq 4
        expect(parsed[0]).to eq(["Url", "Time Uploaded", "Id", "Title", "Depositor", "Creator", "Visibility", "Resource Type", "Rights", "File Format"])
        expect(parsed[1]).to include("CSV Multifile-Report 1")
        expect(parsed[2]).to include("CSV Multifile-Report 2")
        expect(parsed[3]).to include("CSV Multifile-Report 3")
      end
    end
  end
end
