# frozen_string_literal: true

require 'rails_helper'

describe 'curation_concerns/base/_form_doi_component.html.erb' do
  subject { rendered }

  let(:form) { CurationConcerns::GenericWorkForm.new(GenericWork.new, nil) }

  before do
    allow(ENV).to receive(:fetch).with('doi_enabled', 'true').and_return(doi_enabled)
    view.simple_form_for(form) do |f|
      render 'curation_concerns/base/form_doi_component.html.erb', f: f
    end
  end

  context 'with doi' do
    let(:doi_enabled) { 'true' }

    it { is_expected.to include('Create a DOI for this work') }
  end

  context 'without doi' do
    let(:doi_enabled) { 'false' }

    it { is_expected.not_to include('Create a DOI for this work') }
  end
end
