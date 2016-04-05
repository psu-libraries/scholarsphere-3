# frozen_string_literal: true
require 'spec_helper'

describe FileSetPresenter do
  let(:solr_document) { SolrDocument.new(file.to_solr) }
  let(:ability)       { double "Ability" }
  let(:presenter)     { described_class.new(solr_document, ability) }

  subject { presenter }

  describe "#related_files" do
    let(:file) { build(:file_set) }
    its(:related_files) { is_expected.to be_empty }
  end
end
