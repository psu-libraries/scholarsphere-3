# frozen_string_literal: true
require 'spec_helper'

describe GenericFilesController, type: :controller do
  routes { Sufia::Engine.routes }
  context "public user" do
    let(:gf) {
      GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups: ['public']).tap do |gf|
        gf.apply_depositor_metadata("mjg36")
        gf.save!
      end
    }

    describe "#show" do
      it "creates loads from solr" do
        expect_any_instance_of(CanCan::ControllerResource).not_to receive(:load_and_authorize_resource)
        get :show, id: gf.id
        expect(assigns[:generic_file].readonly?).to be_truthy # we get a read only object if it is loaded from solr
      end
    end
  end

  context "when the GenericFile doesn't exist" do
    it "renders the 404 page" do
      get :show, id: 'non-existent-id'
      expect(response.status).to eq(404)
    end
  end

  context "when file is registered" do
    let(:gf) {
      GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], read_groups: ['registered']).tap do |gf|
        gf.apply_depositor_metadata("mjg36")
        gf.save!
      end
    }
    it "redirects with file in url" do
      get :show, id: gf.id
      expect(response.status).to eq(302)
      expect(session[:user_return_to]).to include(Sufia::Engine.routes.url_helpers.generic_file_path(gf))
    end
  end
end
