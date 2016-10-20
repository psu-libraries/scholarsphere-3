# frozen_string_literal: true
require 'rails_helper'
require 'rake'

describe "scholarsphere:harvest" do
  before { load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere-harvest.rake"] }

  context "when harvesting lexvo languages" do
    it 'loads the terms from the rdf file' do
      expect(RDFAuthorityImporter).to receive(:import_languages).with('rdfxml_file')
      run_task('scholarsphere:harvest:lexvo_languages', 'rdfxml_file')
    end
  end

  context "when harvesting LC subjects" do
    it 'loads the terms from the rdf file' do
      expect(RDFAuthorityImporter).to receive(:import_subjects).with('rdfxml_file')
      run_task('scholarsphere:harvest:lc_subjects', 'rdfxml_file')
    end
  end
end
