# frozen_string_literal: true

require 'rails_helper'

describe CurationConcerns::FileSetsController, type: :controller do
  describe '::show_presenter' do
    its(:show_presenter) { is_expected.to eq(::FileSetPresenter) }
  end

  describe 'update' do
    let(:user) { create(:user) }
    let(:file_set) { create :file_set, title: ['abc123'], user: user }
    let(:params) do
      {
        visibility: 'embargo',
        visibility_during_embargo: 'restricted',
        embargo_release_date: '2000-06-08',
        visibility_after_embargo: 'open'
      }
    end

    before do
      allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login)
      allow_any_instance_of(User).to receive(:groups).and_return([])
    end

    it 'handles an error in the data' do
      post :update, params: { id: file_set.id, file_set: params }, format: :html
      expect(response.status).to eq(422)
      expect(flash[:error]).to eq('There was a problem processing your request.')
    end

    context 'solr error' do
      before do
      end

      it 'handles an error in the data' do
        expect(controller).to receive(:update_metadata).and_raise(RSolr::Error::Http.new(controller.request, response))
        post :update, params: { id: file_set.id, file_set: { title: 'abc123' } }, format: :html
        expect(response.status).to eq(200)
        expect(flash[:error]).to start_with('RSolr::Error::Http - ')
      end
    end
  end
end
