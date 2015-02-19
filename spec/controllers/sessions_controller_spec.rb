require 'spec_helper'

describe SessionsController, type: :controller do
  describe "routing" do
    it "should send /logout to sessions#destroy" do
      expect({ get: '/logout' }).to route_to(controller: 'sessions', action: 'destroy')
      expect(destroy_user_session_path).to eq('/logout')
    end
    it "should send /login to sessions#new" do
      expect({ get: '/login' }).to route_to(controller: 'sessions', action: 'new')
      expect(new_user_session_path).to eq('/login')
    end
  end
  describe "#destroy" do
    it "should redirect to the central logout page and destroy the cookie" do
      request.env['COSIGN_SERVICE'] = 'cosign-gamma-ci.dlt.psu.edu'
      expect(cookies).to receive(:delete).with('cosign-gamma-ci.dlt.psu.edu')
      get :destroy
      expect(response).to redirect_to Sufia::Engine.config.logout_url
    end
  end
  describe "#new" do
    it "should redirect to the central login page" do
      get :new
      expect(response).to redirect_to Sufia::Engine.config.login_url
    end
  end
end
