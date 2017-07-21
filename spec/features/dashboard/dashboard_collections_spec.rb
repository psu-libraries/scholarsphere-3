# frozen_string_literal: true
require "feature_spec_helper"

include Selectors::Dashboard

describe "Dashboard Collections:", type: :feature do
  let!(:jill_collection) { create(:collection, title: ["Jill's Collection"], depositor: jill.login) }
  let!(:collection)      { create(:collection, depositor: current_user.login) }

  let(:current_user) { create(:user) }
  let(:jill)         { create(:jill) }

  before do
    sign_in_with_js(current_user)
    go_to_dashboard_collections
  end

  specify "tab title and buttons" do
    expect(page).to have_content("My Collections")
    expect(page).to have_link("New Work", visible: false) # link is there (even if collapsed)
    expect(page).to have_link("New Collection", visible: false) # link is there (even if collapsed)
    expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
  end

  specify "collections are displayed in the Collections list" do
    expect(page).to have_content collection.title.first
    expect(page).not_to have_content jill_collection.title
  end

  specify "toggle displays additional information" do
    first("span.glyphicon-chevron-right").click
    expect(page).to have_content(collection.creator.first)
    expect(page).to have_content(collection.depositor)
    expect(page).to have_content "Edit Access"
    expect(page).to have_content(current_user)
  end

  specify "additional information is hidden" do
    expect(page).not_to have_content(collection.creator.first)
    expect(page).not_to have_content(collection.depositor)
    expect(page).not_to have_content "Edit Access"
    expect(page).not_to have_content(current_user)
  end

  specify "toggle addtitional actions" do
    expect(page).not_to have_content("Edit Collection")
    expect(page).not_to have_content("Delete Collection")
    within('#documents') do
      first(".btn.dropdown-toggle").click
    end
    expect(page).to have_content("Edit Collection")
    expect(page).to have_content("Delete Collection")
  end

  specify "collections are not displayed in the Works list" do
    go_to_dashboard_works
    expect(page).not_to have_content collection.title
  end

  describe "facets," do
    specify "displays the correct totals for each facet" do
      within("#facets") do
        click_link("Object Type")
        expect(page).to have_content("Collection (1)")
        click_link("Creator")
        expect(page).to have_content("#{collection.creator.first} (1)")
      end
    end
  end
end
