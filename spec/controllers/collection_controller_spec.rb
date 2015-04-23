require 'spec_helper'

describe CollectionsController, type: :controller do
  routes { Hydra::Collections::Engine.routes }
  context "when the Collection doesn't exist" do
    it "renders the 404 page" do
      get :show, id: 'non-existent-collection'
      expect(response.status).to eq(404)
    end
  end

  context "when requesting a legacy URL" do
    it "redirects to the proper URL" do
      get :show, id: 'scholarsphere:123'
      expect(response.status).to eq(301)
      expect(response.location).to eq("http://test.host/collections/123")
    end
  end

  context "when requesting an existing collection" do
    let(:collection) do
      Collection.create(title: "My collection",
          description: "My incredibly detailed description of the collection") do |c|
          c.apply_depositor_metadata("cam156")
      end
    end
    let(:resp) { double() }
    let(:document_list) {[{ Solrizer.solr_name(:file_size, :symbol)=>["20"] }, { Solrizer.solr_name(:file_size, :symbol)=>["20"] } ]}
    before do
      allow(resp).to receive(:documents).and_return(document_list)
      allow(controller).to receive(:query_documents).with({"facet.field"=>[],
                                                               "facet.query"=>[],
                                                               "facet.pivot"=>[],
                                                               "fq"=>["{!join from=hasCollectionMember_ssim to=id}id:#{collection.id}"],
                                                               "hl.fl"=>[],
                                                               "rows"=>0,
                                                               "fl"=>["file_size_ssim"]}).and_return(resp)
    end
    it "set the presenter size correctly" do
      get :show, id: collection.id, per_page: 1, page: 2
      expect(assigns(:presenter).size).to eq "40 Bytes"
    end
  end
end
