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

end
