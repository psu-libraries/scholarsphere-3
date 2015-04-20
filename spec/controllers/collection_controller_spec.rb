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
      allow(controller).to receive(:query_documents).with({"facet.field"=>
                                                                  ["resource_type_sim",
                                                                   "collection_sim",
                                                                   "creator_sim",
                                                                   "tag_sim",
                                                                   "subject_sim",
                                                                   "language_sim",
                                                                   "based_near_sim",
                                                                   "publisher_sim",
                                                                   "file_format_sim",
                                                                   "active_fedora_model_ssi"],
                                                               "facet.query"=>[],
                                                               "facet.pivot"=>[],
                                                               "fq"=>
                                                                    ["edit_access_group_ssim:public OR discover_access_group_ssim:public OR read_access_group_ssim:public",
                                                                         "{!join from=hasCollectionMember_ssim to=id}id:#{collection.id}",
                                                                         "edit_access_group_ssim:public OR discover_access_group_ssim:public OR read_access_group_ssim:public"],
                                                              "hl.fl"=>[],
                                                              "qt"=>"search",
                                                              "rows"=>0,
                                                              "facet"=>true,
                                                              "f.resource_type_sim.facet.limit"=>6,
                                                              "f.collection_sim.facet.limit"=>6,
                                                              "f.creator_sim.facet.limit"=>6,
                                                              "f.tag_sim.facet.limit"=>6,
                                                              "f.subject_sim.facet.limit"=>6,
                                                              "f.language_sim.facet.limit"=>6,
                                                              "f.based_near_sim.facet.limit"=>6,
                                                              "f.publisher_sim.facet.limit"=>6,
                                                              "f.file_format_sim.facet.limit"=>6,
                                                              "sort"=>"score desc, date_uploaded_dtsi desc",
                                                              "fl"=>["file_size_ssim"]}).and_return(resp)
    end
    it "set the presenter size correctly" do
      get :show, id: collection.id
      expect(assigns(:presenter).size).to eq "40 Bytes"
    end
  end
end
