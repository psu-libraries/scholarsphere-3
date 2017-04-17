# frozen_string_literal: true
require 'rails_helper'

describe "curation_concerns/file_sets/_single_use_links.html.erb" do
  let(:user)      { create(:user) }
  let(:solr_doc)  { SolrDocument.new(build(:file_set, id: "1234").to_solr) }
  let(:ability)   { Ability.new(user) }
  let(:presenter) { FileSetPresenter.new(solr_doc, ability) }

  context "when no links are present" do
    before { render "curation_concerns/file_sets/single_use_links", presenter: presenter }
    it "renders accessible text" do
      expect(rendered).to have_content("No links present. To create a new link, click Create Single-Use Link")
    end
  end

  context "when links are present" do
    let(:sul_presenter) { CurationConcerns::SingleUseLinkPresenter.new(create(:single_use_link)) }
    let(:page) { Capybara::Node::Simple.new(rendered) }
    let(:copy_button) { page.find('button.copy-single-use-link')['aria-label'] }
    let(:delete_link) { page.find('a.delete-single-use-link')['aria-label'] }

    before do
      controller.params = { id: "fs-id" }
      allow(presenter).to receive(:single_use_links).and_return([sul_presenter])
      render "curation_concerns/file_sets/single_use_links", presenter: presenter
    end

    it "renders accessible actions" do
      expect(page).to have_content("Link id #{sul_presenter.short_key} expires in 23 hours")
      expect(copy_button).to eq("Copy link id #{sul_presenter.short_key} to clipboard")
      expect(delete_link).to eq("Delete link id #{sul_presenter.short_key}")
    end
  end
end
