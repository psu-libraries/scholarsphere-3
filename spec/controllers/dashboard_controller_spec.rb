require 'spec_helper'

describe DashboardController, type: :controller do
  routes { Sufia::Engine.routes }
  let(:user)      { FactoryGirl.find_or_create(:archivist) }
  let(:strategy)  { Devise::Strategies::HttpHeaderAuthenticatable.new(nil) }
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  # This doesn't really belong here, but it works for now
  describe "authenticate!" do
    before do
      allow(request).to receive(:headers).and_return('REMOTE_USER' => user.login)
      allow(strategy).to receive(:request).and_return(request)
    end
    it "should populate LDAP attrs if user is new" do
      allow(User).to receive(:find_by_login).with(user.login).and_return(nil)
      expect(User).to receive(:create).with(login: user.login, email:user.login).once.and_return(user)
      expect_any_instance_of(User).to receive(:populate_attributes).once
      expect(strategy).to be_valid
      expect(strategy.authenticate!).to eq(:success)
      sign_in user
      get :index
      expect(response).to be_success
    end
    it "should not populate LDAP attrs if user is not new" do
      allow(User).to receive(:find_by_login).with(user.login).and_return(user)
      expect(User).to receive(:create).with(login: user.login).never
      expect_any_instance_of(User).to receive(:populate_attributes).never
      expect(strategy).to be_valid
      expect(strategy.authenticate!).to eq(:success)
      sign_in user
      get :index
      expect(response).to be_success
    end
  end

  describe "#index" do
    context "with a logged in user" do
      before do
        sign_in user
        allow_any_instance_of(User).to receive(:groups).and_return([])
        xhr :get, :index
      end
      it "should be a success" do
        expect(response).to be_success
        expect(response).to render_template('dashboard/index')
      end
      it "should return a list of transfers" do
        expect(assigns(:incoming)).to eq(ProxyDepositRequest.where(receiving_user_id: user.id).reject &:deleted_file?)
        expect(assigns(:outgoing)).to eq(ProxyDepositRequest.where(sending_user_id: user.id))
      end
    end

    context "without a user" do
      it "should return an error" do
        xhr :get, :index
        expect(response).not_to be_success
      end
    end
  end

end
