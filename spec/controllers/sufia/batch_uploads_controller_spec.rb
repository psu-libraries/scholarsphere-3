# frozen_string_literal: true

require 'rails_helper'

describe Sufia::BatchUploadsController do
  it 'concern type is a GenericWork' do
    expect(described_class.curation_concern_type).to eq(::BatchUploadItem)
  end
  it 'form service is a BatchUploadFormService' do
    expect(described_class.work_form_service).to eq(::BatchUploadFormService)
  end

  describe '#create' do
    routes { Sufia::Engine.routes }
    let(:user) { create(:user) }

    before { sign_in user }

    context 'queuing a update job' do
      let(:expected_types)             { { '1' => 'Article' } }
      let(:expected_individual_params) { { '1' => 'foo' } }

      let(:expected_attributes_for_actor) do
        { 'keyword' => [], 'visibility' => 'open', 'remote_files' => [], 'uploaded_files' => ['1'] }
      end

      let(:params) do
        {
          title: { '1' => 'foo' },
          resource_type: { '1' => 'Article' },
          uploaded_files: ['1'],
          batch_upload_item: { keyword: [''], visibility: 'open', payload_concern: 'GenericWork' }
        }
      end

      it 'is successful' do
        expect(BatchCreateJob).to receive(:perform_later)
          .with(user,
                expected_individual_params,
                expected_types,
                expected_attributes_for_actor,
                Sufia::BatchCreateOperation)
        post :create, params: params
        expect(response).to redirect_to Sufia::Engine.routes.url_helpers.dashboard_works_path
        expect(flash[:notice]).to include('Your files are being processed')
      end
    end

    context 'when providing a collection' do
      let(:params) do
        {
          title: { '1' => 'foo' },
          resource_type: { '1' => 'Article' },
          uploaded_files: ['1'],
          batch_upload_item: { keyword: [''], visibility: 'open', payload_concern: 'GenericWork', collection_ids: ['collection-id'] }
        }
      end

      before { allow(BatchCreateJob).to receive(:perform_later) }

      it 'redirects to the collection show page' do
        post :create, params: params
        expect(response).to redirect_to('/collections/collection-id')
        expect(flash[:notice]).to include('Your files are being processed')
      end
    end
  end

  describe '#uploading_on_behalf_of?' do
    subject { described_class.new }

    before { allow(subject).to receive(:hash_key_for_curation_concern).and_return(:generic_work) }

    context 'without a proxy' do
      before { allow(subject).to receive(:params).and_return(generic_work: {}) }

      its(:uploading_on_behalf_of?) { is_expected.to be false }
    end

    context 'with a proxy' do
      before { allow(subject).to receive(:params).and_return(generic_work: { on_behalf_of: 'joe' }) }

      its(:uploading_on_behalf_of?) { is_expected.to be true }
    end
  end
end
