# frozen_string_literal: true
require 'rails_helper'

describe "collections/_sort_and_per_page.html.erb" do
  let(:collection) { build(:collection, id: "coll1") }
  let(:page)       { Capybara::Node::Simple.new(rendered) }

  before do
    assign(:response, solr_response)
    controller.stub(:params).and_return(action: "edit")
    render "collections/sort_and_per_page", collection: collection
  end

  context "when the collection has only one work" do
    let(:solr_response) { Blacklight::Solr::Response.new({ response: { numFound: 1 } }, nil) }
    it "renders the button for removing the item from the collection" do
      expect(page.find(".collection-remove-selected").value).to eq("Remove From Collection")
    end
  end

  context "when the collection has no works" do
    let(:solr_response) { Blacklight::Solr::Response.new({ response: { numFound: 0 } }, nil) }
    it "does not render the button for removing the item from the collection" do
      expect(page).not_to have_selector(".collection-remove-selected")
    end
  end
end
