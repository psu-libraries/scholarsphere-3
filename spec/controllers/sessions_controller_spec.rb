# frozen_string_literal: true
require 'rails_helper'

describe SessionsController, type: :controller do
  describe "routing" do
    it "sends /logout to sessions#destroy" do
      expect(get: '/logout').to route_to(controller: 'sessions', action: 'destroy')
      expect(destroy_user_session_path).to eq('/logout')
    end
    it "sends /login to sessions#new" do
      expect(get: '/login_session').to route_to(controller: 'sessions', action: 'new')
      expect(new_user_session_path).to eq('/login_session')
    end
  end
  describe "#destroy" do
    it "redirects to the central logout page and destroy the cookie" do
      request.env['COSIGN_SERVICE'] = 'cosign-gamma-ci.dlt.psu.edu'
      expect(cookies).to receive(:delete).with('cosign-gamma-ci.dlt.psu.edu')
      get :destroy
      expect(response).to redirect_to Sufia::Engine.config.logout_url
    end
  end
  describe "#new" do
    it "redirects to the central login page" do
      get :new
      expect(response).to redirect_to Sufia::Engine.config.login_url
    end

    context "when user_return_to is set" do
      it "does not redirect to the central login page" do
        session["user_return_to"] = "http://return_to_me"
        get :new
        expect(response.redirect_url).to include "http://return_to_me"
      end
    end
  end
end
