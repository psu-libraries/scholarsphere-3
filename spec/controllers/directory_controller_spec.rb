# frozen_string_literal: true
require 'spec_helper'

describe DirectoryController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:user) { create(:user) }
  describe "#user" do
    it "gets an existing user" do
      allow(User).to receive(:directory_attributes).and_return('{"attr":"abc"}')
      get :user, uid: user.id
      expect(response).to be_success
      expect { JSON.parse(response.body) }.not_to raise_error
      results = JSON.parse(response.body)
      expect(results["attr"]).to eq("abc")
    end
  end
end
