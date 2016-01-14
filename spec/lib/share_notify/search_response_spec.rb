require 'spec_helper'
require 'support/vcr'

describe ShareNotify::SearchResponse do
  before { WebMock.enable! }

  after { WebMock.disable! }

  let(:api) { ShareNotify::API.new }

  context "with a nil response" do
    subject { described_class.new(api.response) }
    it "raises an ArgumentError" do
      expect { subject }.to raise_error(ArgumentError, "API response is nil")
    end
  end

  context "with a set of results" do
    let(:query) { api.search("shareProperties.source:scholarsphere") }
    subject { described_class.new(query) }
    it "reports on search results" do
      VCR.use_cassette('share_search', record: :none) do
        expect(subject.count).to eq(3)
        expect(subject.response).to be_kind_of(Hash)
        expect(subject.docs.last).to be_kind_of(ShareNotify::SearchResponse::Document)
        expect(subject.docs.first.title).to eq("M obit251.jpg")
        expect(subject.docs.first.contributors).to contain_exactly("email" => "agw13@psu.ed", "name" => "Wead, Adam Garner")
        expect(subject.docs.first.doc_id).to eq("https://pooh.local/files/ht24wj56k")
        expect(subject.docs.first.source).to eq("scholarsphere")
        expect(subject.docs.first.updated).to eq(Time.parse("2015-12-14T20:24:29Z"))
        expect(subject.docs.first.canonical_uri).to eq("https://pooh.local/files/ht24wj56k")
        expect(subject.docs.first.provider_uris).to contain_exactly("https://pooh.local/files/ht24wj56k")
      end
    end
  end
end
