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
        get :show, id: gf.noid
        expect(response).not_to redirect_to(action: 'show')
        expect(assigns[:generic_file].inner_object.class).to eq ActiveFedora::SolrDigitalObject
      end
    end
  
  end
end
