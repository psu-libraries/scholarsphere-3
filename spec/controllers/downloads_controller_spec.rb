# frozen_string_literal: true
require 'rails_helper'

describe DownloadsController do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:file)       { File.open(File.join(fixture_path, 'world.png')) }
  let(:my_file)    { create(:file_set, user: user, content: file) }
  let(:other_file) { create(:file_set, user: other_user, content: file) }

  before { allow_any_instance_of(Devise::Strategies::HttpHeaderAuthenticatable).to receive(:remote_user).and_return(user.login) }

  describe "#authorize_download!" do
    subject { controller.send(:authorize_download!) }

    context "with a regular user" do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return([])
      end

      context "with my own file" do
        before { get :show, id: my_file.id }
        it { is_expected.to eq(my_file.id) }
      end

      context "with a file I do not have read access to" do
        before { get :show, id: other_file.id }
        it "denies access" do
          expect { subject }.to raise_error(CanCan::AccessDenied)
        end
      end
    end

    context "with an administrator" do
      before do
        allow_any_instance_of(User).to receive(:groups).and_return(["umg/up.dlt.scholarsphere-admin-viewers"])
      end

      context "with my own file" do
        before { get :show, id: my_file.id }
        it { is_expected.to eq(my_file.id) }
      end

      context "with a file I do not have read access to" do
        before { get :show, id: other_file.id }
        it { is_expected.to eq(other_file.id) }
      end
    end
  end
end
