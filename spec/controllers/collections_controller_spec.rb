# frozen_string_literal: true
require 'spec_helper'

describe CollectionsController, type: :controller do
  subject { response }

  context "when the Collection doesn't exist" do
    before { get :show, id: 'non-existent-collection' }
    its(:status) { is_expected.to eq(302) }      
  end

  context "when requesting a legacy URL" do
    before { get :show, id: 'scholarsphere:123' }
    its(:status) { is_expected.to eq(301) }
    its(:location) { is_expected.to eq("http://test.host/collections/123") }
  end

  context "when requesting an existing collection" do
    let(:work1)       { build(:public_work, id: "1") }
    let(:work2)       { build(:public_work, id: "2") }
    let!(:collection) { create(:public_collection, members: [work1, work2]) }
    before { get :show, id: collection.id, per_page: 1, page: 2 }
    it { 
      pending("CollectionController not setting per_page?")
      is_expected.to be_success
    }
  end
end
