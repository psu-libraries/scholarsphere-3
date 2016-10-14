# frozen_string_literal: true
require 'rails_helper'

describe Collection do
  subject { collection }
  context "with no attached files" do
    let(:collection) { build(:collection) }
    its(:bytes) { is_expected.to eq(0) }
  end

  context "with attached files" do
    let!(:collection) { create(:public_collection, members: [work1, work2]) }

    let(:work1)       { build(:public_work, id: "1") }
    let(:work2)       { build(:public_work, id: "2") }
    let(:resp) do
      [{ Solrizer.solr_name(:file_size, CurationConcerns::FileSetIndexer::STORED_INTEGER) => "20" }]
    end

    before { allow(ActiveFedora::SolrService).to receive(:query).and_return(resp) }
    its(:bytes) { is_expected.to eq(40) }
  end
end
