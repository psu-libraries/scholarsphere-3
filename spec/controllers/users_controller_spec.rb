# frozen_string_literal: true

require 'rails_helper'

describe UsersController, type: :controller do
  let(:user) { create(:user, login: 'abc123') }
  let!(:agent) { create(:agent, psu_id: user.login) }

  before { sign_in user }
  routes { Sufia::Engine.routes }

  describe '#update' do
    it 'updates the orcid and copies the orcid to the agent' do
      expect(agent.orcid_id).to eq nil
      put :update, user: { 'orcid' => 'http://orcid.org/1234-5678-9012-0000', 'twitter_handle' => '',
                           'facebook_handle' => '', 'googleplus_handle' => '' },
                   id: user.login
      expect(response).to be_redirect
      user.reload.orcid
      expect(user.orcid).to eq 'http://orcid.org/1234-5678-9012-0000'
      expect(agent.reload.orcid_id).to eq 'http://orcid.org/1234-5678-9012-0000'
    end
  end
end
