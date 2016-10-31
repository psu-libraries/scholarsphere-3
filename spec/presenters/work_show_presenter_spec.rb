# frozen_string_literal: true
require 'rails_helper'

describe WorkShowPresenter do
  let(:work)      { build(:work) }
  let(:solr_doc)  { SolrDocument.new(work.to_solr) }
  let(:ability)   { Ability.new(nil) }
  let(:presenter) { described_class.new(solr_doc, ability) }

  subject { presenter }

  describe "#size" do
    before { allow(work).to receive(:bytes).and_return("2048") }
    its(:size) { is_expected.to eq("2 KB") }
  end

  describe "#total_items" do
    context "with no files in the work" do
      its(:total_items) { is_expected.to eq(0) }
    end

    context "with two files in the work" do
      let(:solr_doc)    { SolrDocument.new(work.to_solr).merge!('member_ids_ssim' => ["thing1", "thing2"]) }
      its(:total_items) { is_expected.to eq(2) }
    end
  end

  describe "#member_presenters" do
    let(:work) { create(:public_work, ordered_members: [file_set1, file_set2]) }

    subject { presenter.member_presenters }

    context "when the current user has read access to all file sets" do
      let(:file_set1) { create(:file_set, :public) }
      let(:file_set2) { create(:file_set, :public) }
      its(:count) { is_expected.to eq(2) }
    end

    context "when the current user does not have read access to all file sets" do
      let(:file_set1) { create(:file_set, :public) }
      let(:file_set2) { create(:file_set) }
      its(:count) { is_expected.to eq(1) }
    end
  end
end
