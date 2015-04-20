require 'spec_helper'

describe CollectionPresenter do
  describe "#terms" do
    subject { described_class.terms }
    it { is_expected.to eq [:title, :description, :total_items, :size, :creator,
                            :date_modified, :date_uploaded] }
  end

  describe "bytes" do
    subject { described_class.new(nil) }
    before do
      subject.size = 333
    end

    it { expect(subject[:size]).to eq "333 Bytes" }
  end
end
