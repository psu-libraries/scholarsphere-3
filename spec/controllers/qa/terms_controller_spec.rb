# frozen_string_literal: true

require 'rails_helper'

describe Qa::TermsController do
  # NB: Although technically a controller test, this tests the integration of Questioning Authority's
  # local table-based language and subject authorities with Scholarsphere.
  routes { Qa::Engine.routes }

  describe '#search' do
    subject { response }

    context 'with languages' do
      let(:parameters) { { 'q' => 'Alu', 'vocab' => 'local', 'subauthority' => 'languages' } }

      before do
        LanguageAuthorityImportJob.perform_now(File.join(fixture_path, 'lexvo_snippet.rdf'))
        get :search, parameters
      end

      its(:body) { is_expected.to eq('[{"id":"http://lexvo.org/id/iso639-3/aab","label":"Alumu-Tesu"}]') }
    end

    context 'with subjects' do
      let(:parameters) { { 'q' => 'Rio', 'vocab' => 'local', 'subauthority' => 'subjects' } }

      before do
        SubjectAuthorityImportJob.perform_now(File.join(fixture_path, 'loc_subjects_snippet.rdfxml.skos'))
        get :search, parameters
      end

      its(:body) { is_expected.to eq('[{"id":"http://id.loc.gov/authorities/subjects/sh00000024","label":"Rio Oscuro (N.M.)"}]') }
    end
  end
end
