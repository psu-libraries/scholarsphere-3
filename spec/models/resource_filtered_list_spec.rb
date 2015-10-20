require 'spec_helper'

describe ResourceFilteredList, type: :model do
  let(:file_list) do
    [ GenericFile.new(title: ["Dataset"], resource_type: ["Dataset"]),
      GenericFile.new(title: ["Posters"], resource_type: ["Posters"]),
      GenericFile.new(title: ["Thesis"], resource_type: ["Thesis"]),
      GenericFile.new(title: ["Dissertation"], resource_type: ["Dissertation"]),
      GenericFile.new(title: ["Report"], resource_type: ["Report"]),
      GenericFile.new( title: ['none'])
    ]
  end

  context "when using default resource types" do
    subject {ResourceFilteredList.new(file_list).filter}

    it "keeps default resource types" do
      expect(subject.count).to eq(5)
      expect(subject.map(&:title)).to include(['Dataset'])
      expect(subject.map(&:title)).to include(['Posters'])
      expect(subject.map(&:title)).to include(['Thesis'])
      expect(subject.map(&:title)).to include(['Dissertation'])
      expect(subject.map(&:title)).to include(['Report'])
      expect(subject.map(&:title)).not_to include(['none'])
    end
  end

  context "when using other resource types" do
    subject {ResourceFilteredList.new(file_list,['Dataset', 'Report']).filter}

    it "keeps default resource types" do
      expect(subject.count).to eq(2)
      expect(subject.map(&:title)).to include(['Dataset'])
      expect(subject.map(&:title)).to include(['Report'])
      expect(subject.map(&:title)).not_to include(['Posters'])
      expect(subject.map(&:title)).not_to include(['Thesis'])
      expect(subject.map(&:title)).not_to include(['Dissertation'])
      expect(subject.map(&:title)).not_to include(['none'])
    end
  end

end