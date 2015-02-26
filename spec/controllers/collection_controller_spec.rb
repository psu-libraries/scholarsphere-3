require 'spec_helper'

describe CollectionsController, type: :controller do
  routes { Hydra::Collections::Engine.routes }
  context "when the Collection doesn't exist" do
    it "renders the 404 page" do
      get :show, id: 'non-existent-collection'
      expect(response.status).to eq(404)
    end
  end
end
