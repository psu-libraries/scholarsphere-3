require 'spec_helper'

describe TransfersController do
  describe "with a signed in user" do

    before do
      @user = FactoryGirl.find_or_create(:user)
      @another_user = FactoryGirl.find_or_create(:test_user_1)
      controller.stubs(:clear_session_user) ## Don't clear out the authenticated session
      sign_in @user
    end

    describe "#index" do
      before do
        @incoming_file = GenericFile.new.tap do |f|
          f.apply_depositor_metadata(@another_user.user_key)
          f.save!
          f.request_transfer_to(@user)
        end
        @outgoing_file = GenericFile.new.tap do |f|
          f.apply_depositor_metadata(@user.user_key)
          f.save!
          f.request_transfer_to(@another_user)
        end
      end
      it "should be successful" do
        get :index
        response.should be_success
        assigns[:incoming].first.should be_kind_of ProxyDepositRequest
        assigns[:incoming].first.pid.should == @incoming_file.pid

        assigns[:outgoing].first.should be_kind_of ProxyDepositRequest
        assigns[:outgoing].first.pid.should == @outgoing_file.pid
      end
    end

    describe "#accept" do

      context "when I am the receiver" do
        before do
          @incoming_file = GenericFile.new.tap do |f|
            f.apply_depositor_metadata(@another_user.user_key)
            f.save!
            f.request_transfer_to(@user)
          end
        end
        it "should be successful" do
          post :accept, id: @user.proxy_deposit_requests.first
          response.should redirect_to transfers_path
          flash[:notice].should == "Transfer complete"
        end
      end

      context "accepting one that isn't mine" do
        before do
          @incoming_file = GenericFile.new.tap do |f|
            f.apply_depositor_metadata(@user.user_key)
            f.save!
            f.request_transfer_to(@another_user)
          end
        end
        it "should not allow me" do
          post :accept, id: @another_user.proxy_deposit_requests.first
          response.should redirect_to root_path
          flash[:alert].should == "You are not authorized to access this page."
        end
      end
    end
  end
end
