require 'spec_helper'
require 'support/vcr'

describe ShareNotify::Metadata do
  before(:all) do
    class MockObject
      include ShareNotify::Metadata
    end
  end

  after(:all) { Object.send(:remove_const, :MockObject) if defined?(MockObject) }

  before { WebMock.enable! }
  after { WebMock.disable! }

  let(:object) { MockObject.new }

  describe "#share_notified?" do
    subject { object.share_notified? }
    context "when object is already in SHARE" do
      let(:url) { "http://example.com/document1" }
      before { allow(object).to receive(:url).and_return(url) }
      specify do
        VCR.use_cassette('share_metadata', record: :none) do
          is_expected.to be true
        end
      end
    end
    context "when object is not in SHARE" do
      let(:url) { "http://example.com/bogusDoc" }
      before { allow(object).to receive(:url).and_return(url) }
      specify do
        VCR.use_cassette('share_metadata', record: :none) do
          is_expected.to be false
        end
      end
    end
  end
end
