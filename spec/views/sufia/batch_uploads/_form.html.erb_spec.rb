# frozen_string_literal: true
require 'rails_helper'

describe 'sufia/batch_uploads/_form.html.erb' do
  let(:form) { BatchUploadForm.new(BatchUploadItem.new, Ability.new(nil)) }

  before do
    assign(:form, form)
    allow(controller).to receive(:params).and_return(params)
    stub_template '_form_files.html.erb' => ''
    stub_template '_form_metadata.html.erb' => ''
    stub_template '_form_relationships.html.erb' => ''
    stub_template '_form_share.html.erb' => ''
    stub_template '_form_progress.html.erb' => ''
    render 'sufia/batch_uploads/form.html.erb'
  end

  describe 'rendering the link that switches to the new single work page' do
    subject { rendered }

    context 'without no collection id parameters' do
      let(:params) { {} }
      it { is_expected.to include('href="/concern/generic_works/new"') }
    end

    context 'with collection ids' do
      let(:params) { { collection_ids: ['collection-id'] } }
      it { is_expected.to include('href="/concern/generic_works/new?collection_ids%5B%5D=collection-id"') }
    end
  end
end
