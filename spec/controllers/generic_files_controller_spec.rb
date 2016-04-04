# frozen_string_literal: true
require 'spec_helper'

describe GenericFilesController, type: :controller do
  routes { Sufia::Engine.routes }
  context "public user" do
    let(:gf) { create(:public_file) }
    describe "#show" do
      it "creates loads from solr" do
        expect_any_instance_of(CanCan::ControllerResource).not_to receive(:load_and_authorize_resource)
        get :show, id: gf.id
        expect(assigns[:generic_file].readonly?).to be_truthy # we get a read only object if it is loaded from solr
        expect(assigns[:generic_file].content).to be_kind_of(ActiveFedora::LoadableFromJson::SolrBackedMetadataFile)
        expect(assigns[:generic_file].content).not_to respond_to(:has_versions?)
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
    let(:gf) { create(:registered_file) }
    it "redirects with file in url" do
      get :show, id: gf.id
      expect(response.status).to eq(302)
      expect(session[:user_return_to]).to include(Sufia::Engine.routes.url_helpers.generic_file_path(gf))
    end
  end

  describe "#delete" do
    let(:user) { create(:user) }
    let!(:file) { create(:share_file, depositor: user.login) }
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end
    it "is deleted from SHARE notify" do
      expect(controller).to receive(:delete_from_share)
      delete :destroy, id: file
    end
  end

  context "when file is private" do
    let(:gf) { create(:private_file) }

    before do
      sign_in user
    end
    context "when user is not administrator" do
      let(:user) { FactoryGirl.create(:user) }

      it "does not allow any user to view" do
        get :show, id: gf.id
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end

      it "does not allow any user to edit" do
        get :edit, id: gf.id
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq("You do not have sufficient privileges to edit this document")
      end

      it "does not allow any user to update" do
        post :update, id: gf.id, generic_file: { title: ['new_title'] }
        expect(response.status).to eq(302)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end

    context "when user is an administrator" do
      let(:user) { FactoryGirl.create(:administrator) }
      let(:update_message) { double('content update message') }
      before do
        allow(ContentUpdateEventJob).to receive(:new).with(gf.id, user.user_key).and_return(update_message)
      end

      it "does allow user to view" do
        get :show, id: gf.id
        expect(response.status).to eq(200)
      end

      it "allows edits" do
        get :edit, id: gf.id
        expect(response.status).to eq(200)
      end

      it "allows updates" do
        expect(Sufia.queue).to receive(:push).with(update_message)
        post :update, id: gf.id, generic_file: { title: ['new_title'] }
      end
    end
  end
end
