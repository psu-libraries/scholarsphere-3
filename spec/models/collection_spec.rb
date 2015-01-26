require 'spec_helper'

describe Collection do
  describe "#bytes" do
    subject { described_class.new.bytes }
    it { is_expected.to eq 0 }
  end
end
