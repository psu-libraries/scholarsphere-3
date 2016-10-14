# frozen_string_literal: true
require 'rails_helper'

describe ResourceFilteredList, type: :model do
  let(:file_list) do
    [
      create(:file, title: ["Dataset"], resource_type: ["Dataset"]),
      create(:file, title: ["Poster"], resource_type: ["Poster"]),
      create(:file, title: ["Thesis"], resource_type: ["Thesis"]),
      create(:file, title: ["Dissertation"], resource_type: ["Dissertation"]),
      create(:file, title: ["Report"], resource_type: ["Report"]),
      create(:file, title: ['none'])
    ]
  end

  context "when using default resource types" do
    subject { described_class.new(file_list).filter }

    it "keeps default resource types" do
      expect(subject.count).to eq(4)
      expect(subject.map(&:title)).to include(['Dataset'])
      expect(subject.map(&:title)).to include(['Poster'])
      expect(subject.map(&:title)).to include(['Thesis'])
      expect(subject.map(&:title)).to include(['Dissertation'])
      expect(subject.map(&:title)).not_to include(['Report'])
      expect(subject.map(&:title)).not_to include(['none'])
    end
  end

  context "when using other resource types" do
    subject { described_class.new(file_list, ['Dataset', 'Report']).filter }

    it "keeps default resource types" do
      expect(subject.count).to eq(2)
      expect(subject.map(&:title)).to include(['Dataset'])
      expect(subject.map(&:title)).to include(['Report'])
      expect(subject.map(&:title)).not_to include(['Poster'])
      expect(subject.map(&:title)).not_to include(['Thesis'])
      expect(subject.map(&:title)).not_to include(['Dissertation'])
      expect(subject.map(&:title)).not_to include(['none'])
    end
  end
end
