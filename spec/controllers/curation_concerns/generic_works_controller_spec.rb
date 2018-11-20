# frozen_string_literal: true

require 'rails_helper'

describe CurationConcerns::GenericWorksController, type: :controller do
  let(:user) { create(:user) }

  describe '#show' do
    context 'with a public user' do
      let(:work) { create(:public_work) }

      it 'loads from solr' do
        expect_any_instance_of(CanCan::ControllerResource).not_to receive(:load_and_authorize_resource)
        get :show, id: work.id
        expect(assigns(:presenter)).to be_kind_of ::WorkShowPresenter
      end
    end

    context "when the work doesn't exist" do
      it 'throws 500 error' do
        get :show, id: 'non-existent-id'
        expect(response.code).to eq('500')
      end
    end

    context 'when work is registered' do
      let(:work)   { create(:registered_file) }
      let(:path)   { Rails.application.routes.url_helpers.curation_concerns_generic_work_path(work) }

      it 'redirects with file in url' do
        get :show, id: work.id
        expect(response.status).to eq(302)
        expect(session[:user_return_to]).to include(path)
      end
    end
  end

  describe '#delete' do
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    context 'when the work has been pushed to Share' do
      let!(:work) { create(:share_file, depositor: user.login) }

      it 'is deleted from SHARE notify' do
        expect(ShareNotifyDeleteJob).to receive(:perform_later).with(work)
        delete :destroy, id: work
      end
    end

    context 'after deletion' do
      let!(:work) { create(:work, depositor: user.login) }

      it 'redirects to My Works' do
        delete :destroy, id: work
        expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.dashboard_works_path)
      end
    end
  end

  describe '#edit' do
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    context 'when files are being uploaded to a work' do
      let!(:work) { create(:work, depositor: user.login) }

      before { allow(QueuedFile).to receive(:where).and_return(['queued file']) }

      it 'redirects' do
        get :edit, id: work
        expect(flash.notice).to eq('Edits or deletes not allowed while files are being uploaded to a work')
        expect(response).to be_redirect
      end
    end
  end

  describe '#update' do
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    let!(:work) { create(:work, depositor: user.login) }
    let(:doi_service) { instance_double(DOIService, run: 'doi:sholder/abc123') }

    it 'allows updates' do
      post :update, id: work.id, generic_work: { title: 'new_title' }
      expect(response.status).to eq(302)
      expect(work.reload.title.first).to eq('new_title')
    end

    context 'replacing with a bad creator' do
      let(:creators) { { '1' => { 'id' => '', 'given_name' => 'sdfsdf', 'sur_name' => '', 'display_name' => '', 'email' => '', 'psu_id' => '', 'orcid_id' => '' } } }

      it 'fails to update' do
        post :update, id: work.id, generic_work: { creators: creators }
        expect(response.status).to eq(422)
        expect(flash[:error]).to contain_exactly('Field: creator, Error: Please provide either an alias, id, or display name; or, all of: surname, given name, and display name')
      end
    end

    it 'creates doi on update' do
      expect(DOIService).to receive(:new).and_return(doi_service)
      expect(doi_service).to receive(:run)
      post :update, id: work.id, generic_work: { create_doi: '1' }
      expect(response.status).to eq(302)
    end
  end

  describe '#create' do
    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
      initialize_default_adminset
      post :create, generic_work: work.attributes.merge('creators' => creators)
    end

    let(:creators) { { '1' => { 'id' => '', 'given_name' => 'Kermit', 'sur_name' => 'The Frog', 'display_name' => 'Kermit the little green Frog', 'email' => '', 'psu_id' => '', 'orcid_id' => '' } } }
    let(:work) { build(:work, depositor: user.login) }

    it 'allows creates' do
      expect(response.status).to eq(302)
      expect(assigns[:curation_concern].creator.map(&:display_name)).to contain_exactly('Kermit the little green Frog')
    end

    context 'replacing with a bad creator' do
      let(:creators) { { '1' => { 'id' => '', 'given_name' => 'sdfsdf', 'sur_name' => '', 'display_name' => '', 'email' => '', 'psu_id' => '', 'orcid_id' => '' } } }

      it 'fails to create' do
        expect(response.status).to eq(422)
        expect(flash[:error]).to contain_exactly('Field: creator, Error: Please provide either an alias, id, or display name; or, all of: surname, given name, and display name')
      end
    end
  end

  context 'when work is private' do
    let(:work) { create(:private_work, id: '1234') }

    before { sign_in user }

    context 'when user is not administrator' do
      let(:user) { FactoryGirl.create(:user) }

      it 'does not allow any user to view' do
        get :show, id: work.id
        expect(response.status).to eq(401)
      end

      it 'does not allow any user to edit' do
        get :edit, id: work.id
        expect(response.status).to eq(401)
      end

      it 'does not allow any user to update' do
        post :update, id: work.id, generic_work: { title: 'new_title' }
        expect(response.status).to eq(401)
      end
    end

    context 'when user is an administrator' do
      let(:user) { FactoryGirl.create(:administrator) }

      it 'does allow user to view' do
        get :show, id: work.id
        expect(response.status).to eq(200)
      end

      it 'allows edits' do
        get :edit, id: work.id
        expect(response.status).to eq(200)
      end

      it 'allows updates' do
        post :update, id: work.id, generic_work: { title: 'new_title' }
        expect(response.status).to eq(302)
        expect(work.reload.title.first).to eq('new_title')
      end
    end
  end
end
