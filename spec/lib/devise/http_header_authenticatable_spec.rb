require 'spec_helper'

describe Devise::Strategies::HttpHeaderAuthenticatable do
  subject { described_class.new(nil) }
  describe "when REMOTE_USER present" do
    let(:headers) { { "REMOTE_USER" => "abc123" } }
    before do
      # I do this in before block or right before test executes
      @request = double(:request)
      expect(@request).to receive(:headers).and_return(headers)
      expect(subject).to receive(:request).and_return(@request)
    end
    it "is valid" do
      expect(subject.valid?).to eq(true)
    end
  end

  describe "when REMOTE_USER is not present" do
    let(:headers) { {} }
    before do
      # I do this in before block or right before test executes
      @request = double(:request)
      expect(@request).to receive(:headers).and_return(headers)
      expect(subject).to receive(:request).and_return(@request)
    end
    it "is valid" do
      expect(subject.valid?).to eq(false)
    end
  end
end
