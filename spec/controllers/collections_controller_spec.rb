# frozen_string_literal: true
require 'rails_helper'

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
    let(:work1)       { create(:public_work) }
    let(:work2)       { create(:public_work) }
    let!(:collection) { create(:public_collection, members: [work1, work2]) }
    before { get :show, id: collection.id, per_page: 1, page: 2 }
    it { is_expected.to be_success }
  end
end
