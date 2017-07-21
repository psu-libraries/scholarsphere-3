# frozen_string_literal: true
require "feature_spec_helper"

describe "catalog searching", type: :feature do
  let(:user)   { create(:jill) }

  let!(:work1) { build(:public_work, id: "pw1",
                                     depositor: user.login,
                                     title: ["title 1"],
                                     description: ["first work"],
                                     date_created: ["just now"],
                                     keyword: ["tag1", "tag2"]) }

  let!(:work2) { build(:public_work, id: "pw2",
                                     depositor: user.login,
                                     title: ["title 2"],
                                     description: ["second work"],
                                     date_created: ["just now"],
                                     keyword: ["tag2", "tag3"]) }

  let!(:work3) { build(:public_work, id: "pw3",
                                     depositor: user.login,
                                     title: ["title 3"],
                                     date_created: ["just now"],
                                     keyword: ["tag3", "tag4"]) }

  let!(:collection) { build(:collection, id: "coll1", depositor: user.login, keyword: ["tag3", "tag4"]) }

  before do
    index_works_and_collections(work1, work2, work3, collection)
    sign_in(user)
    visit "/"
  end

  it "shows the facets" do
    within('#search-form-header') do
      click_button("Go")
    end
    expect(page).to have_css "div#facets"
  end

  it "finds multiple files" do
    within('#search-form-header') do
      fill_in("search-field-header", with: "tag2")
      click_button("Go")
    end

    # All fields are displayed in the list view
    expect(page).to have_selector("h1", text: "Search Results")
    expect(page).to have_selector("fieldset")
    expect(page).to have_selector("legend", text: "Sort Results")
    expect(page).to have_selector("legend", text: "Number of results to display per page")
    expect(page).to have_selector("legend", text: "View results as:")
    expect(page).to have_selector("h2", text: "Listing of Search Results")
    within("#search-results") do
      expect(page).to have_link(work1.title.first)
      expect(page).to have_link(work2.title.first)
      expect(page).not_to have_content(collection.title)
      expect(page).not_to have_content("Title:")
    end

    # Not all fields should be displayed in the gallery view
    click_link("Gallery")
    within("#documents") do
      expect(page).to have_link(work1.title.first)
      expect(page).to have_link(work2.title.first)
      expect(page).not_to have_content(work1.keyword.first)
      expect(page).not_to have_content(work1.keyword.last)
      expect(page).not_to have_content(work2.keyword.first)
      expect(page).not_to have_content(work2.keyword.last)
      expect(page).not_to have_content(collection.title)
      expect(page).not_to have_button("Bookmark")
    end

    expect(page).not_to have_selector("a.view-type-masonry")
    expect(page).not_to have_selector("a.view-type-slideshow")
  end

  it "finds files and collections" do
    within('#search-form-header') do
      fill_in("search-field-header", with: "tag3")
      click_button("Go")
    end
    expect(page).to have_content("Search Results")
    expect(page).to have_content(collection.title.first)
    expect(page).to have_content(work2.title.first)
    expect(page).not_to have_content(work1.title.first)
  end

  it "finds collections" do
    within('#search-form-header') do
      fill_in("search-field-header", with: "tag4")
      click_button("Go")
    end
    expect(page).to have_content("Search Results")
    expect(page).to have_content(collection.title.first)
    expect(page).not_to have_content(work2.title.first)
    expect(page).not_to have_content(work1.title.first)
  end
end
