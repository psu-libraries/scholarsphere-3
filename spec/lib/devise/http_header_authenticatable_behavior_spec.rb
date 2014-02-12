require 'spec_helper'

class AuthenticatableThing
  include Behaviors::HttpHeaderAuthenticatableBehavior
end

describe Behaviors::HttpHeaderAuthenticatableBehavior do
  subject {AuthenticatableThing.new}
  context "development mode" do
    before do
      @old_env = Rails.env
      Rails.env = "development"
    end
    after do
      Rails.env = @old_env
    end
    describe "when REMOTE_USER present" do
      let(:headers) {{"REMOTE_USER"=>"abc123"} }
      it "is valid" do
        subject.valid_user?(headers).should == true
      end
    end
    describe "when HTTP_REMOTE_USER present" do
      let(:headers) { {"HTTP_REMOTE_USER"=>"abc123"} }
      it "is valid" do
        subject.valid_user?(headers).should == true
      end
    end
    describe "when REMOTE_USER not present" do
      let(:headers) {{} }
      it "is not valid" do
        subject.valid_user?(headers).should == false
      end
    end

  end
  context "production mode" do
    before do
      @old_env = Rails.env
      Rails.env = "production"
    end
    after do
      Rails.env = @old_env
    end

    describe "when REMOTE_USER present" do
      let(:headers) { {"REMOTE_USER"=>"abc123"} }
      it "is valid" do
        subject.valid_user?(headers).should == true
      end
    end
    describe "when HTTP_REMOTE_USER present" do
      let(:headers) { {"HTTP_REMOTE_USER"=>"abc123"} }
      it "is not valid" do
        subject.valid_user?(headers).should == false
      end
    end

    describe "when REMOTE_USER not present" do
      let(:headers) {{} }
      it "is not valid" do
        subject.valid_user?(headers).should == false
      end
    end
  end
end
