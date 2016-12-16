# frozen_string_literal: true
require 'rails_helper'

describe Sufia::BatchUploadsController do
  its(:form_class) { is_expected.to eq(::BatchUploadForm) }

  describe "#create" do
    routes { Sufia::Engine.routes }
    let(:user) { create(:user) }

    before { sign_in user }

    context "enquing a update job" do
      let(:expected_types)             { { '1' => 'Article' } }
      let(:expected_individual_params) { { '1' => 'foo' } }

      let(:expected_attributes_for_actor) do
        { 'keyword' => [], 'visibility' => 'open', 'remote_files' => [], 'uploaded_files' => ['1'] }
      end

      let(:params) do
        ActionController::Parameters.new(
          title: { '1' => 'foo' },
          resource_type: { '1' => 'Article' },
          uploaded_files: ['1'],
          batch_upload_item: { keyword: [""], visibility: 'open' }
        )
      end

      it "is successful" do
        expect(BatchCreateJob).to receive(:perform_later)
          .with(user,
                expected_individual_params,
                expected_types,
                expected_attributes_for_actor,
                Sufia::BatchCreateOperation)
        post :create, params
        expect(response).to redirect_to Sufia::Engine.routes.url_helpers.dashboard_works_path
        expect(flash[:notice]).to include("Your files are being processed")
      end
    end
  end
end
