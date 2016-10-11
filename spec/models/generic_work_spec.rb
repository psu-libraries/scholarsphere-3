# frozen_string_literal: true
require 'rails_helper'

describe GenericWork do
  let(:work) { create(:work) }

  subject { work }

  it "creates a noid on save" do
    expect(subject.id.length).to eq 9
  end

  describe "#time_uploaded" do
    context "with a blank date_uploaded" do
      its(:time_uploaded) { is_expected.to be_blank }
    end
    context "with date_uploaded" do
      before { allow(work).to receive(:date_uploaded).and_return(Date.today) }
      its(:time_uploaded) { is_expected.to eq(Date.today.strftime("%Y-%m-%d %H:%M:%S")) }
    end
  end

  describe "#url" do
    its(:url) { is_expected.to end_with("/concern/generic_works/#{work.id}") }
  end

  describe "::indexer" do
    subject { described_class }
    its(:indexer) { is_expected.to eq(WorkIndexer) }
  end
end
