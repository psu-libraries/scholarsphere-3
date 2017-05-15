# frozen_string_literal: true
require 'rails_helper'

describe "shared/_twitter.html.erb" do
  let(:doc)       { SolrDocument.new(build(:work, id: "citation-test").to_solr) }
  let(:presenter) { WorkShowPresenter.new(doc, Ability.new(nil)) }

  subject { rendered }

  context "without a representative file set" do
    before do
      allow(presenter).to receive(:member_presenters).and_return([])
      render "shared/twitter", presenter: presenter
    end

    it { is_expected.to include('<meta property="og:title" content="Sample Title"/>') }
  end

  context "with a file set" do
    let(:fs_doc)       { SolrDocument.new(build(:file_set, id: "citation-download").to_solr) }
    let(:fs_presenter) { FileSetPresenter.new(fs_doc, Ability.new(nil)) }

    before do
      allow(presenter).to receive(:member_presenters).and_return([fs_presenter])
      allow(presenter).to receive(:representative_presenter).and_return(fs_presenter)
      render "shared/twitter", presenter: presenter
    end

    it { is_expected.to include('<meta property="og:image" content="http://test.host/downloads/citation-download?file=thumbnail"/>') }
  end
end
