require 'spec_helper'

describe GenericFilesController, type: :controller do
  routes { Sufia::Engine.routes }
  context "public user" do
    
    let(:gf) {
      GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups:['public']).tap do |gf|
        gf.apply_depositor_metadata("mjg36")
        gf.save!
      end
    }

    describe "#show" do
      it "creates loads from solr" do
        skip "Don't know what this test is for"
        expect_any_instance_of(CanCan::ControllerResource).to receive(:load_and_authorize_resource)
        get :show, id: gf.id
        expect(response).not_to redirect_to(action: 'show')
        expect(assigns[:generic_file].inner_object.class).to eq ActiveFedora::SolrDigitalObject
      end
    end
  
  end

  context "when the GenericFile doesn't exist" do
    it "renders the 404 page" do
      get :show, id: 'non-existent-id'
      expect(response.status).to eq(404)
    end
  end
  
end
