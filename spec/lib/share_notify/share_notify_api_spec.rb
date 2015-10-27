require 'spec_helper'
require 'support/vcr'

describe ShareNotify::API do

  before do
    allow(ShareNotify).to receive(:config) { { "token" => "SECRET_TOKEN" } }
    WebMock.enable!
  end

  after do
    WebMock.disable!
  end

  describe "#get" do
    subject { described_class.new.get }
    it "is successful" do
      VCR.use_cassette('share_notify', record: :none) do
        expect(subject.code).to eq(200)
      end
    end
  end

  describe "#post" do
    let(:post_data) { File.read(File.join(fixture_path, "share.json")) }
    subject { described_class.new.post(post_data) }
    it "is successful" do
      VCR.use_cassette('share_notify', record: :none) do
        expect(subject.code).to eq(201)
      end
    end
  end

  describe "#search" do
    let(:query) { "something" }
    subject { described_class.new.search(query) }
    it "returns results" do
      pending "Contacting OSF support about this..."
      VCR.use_cassette('share_notify', record: :none) do
        expect(subject.code).to eq(200)
      end
    end
  end

end
