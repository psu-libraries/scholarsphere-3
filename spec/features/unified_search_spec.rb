# frozen_string_literal: true
require 'feature_spec_helper'

describe 'unified search', type: :feature do
  let(:subject_value) { 'fffzzz' }
  let(:user)          { create(:jill) }
  let(:other_user)    { create(:archivist) }

  let!(:file1) { create(:public_file, depositor: user.login, title: ['title 1 abc'], keyword: [subject_value]) }
  let!(:file2) { create(:private_file, depositor: user.login, title: ['title 2 abc'], keyword: [subject_value]) }
  let!(:file3) { create(:public_file, depositor: other_user.login, title: ['title 3 abc'], keyword: [subject_value]) }
  let!(:collection) do
    create(:public_collection,
           title: ['collection title abc'],
           description: [subject_value],
           user: user,
           members: [file1, file2]
          )
  end

  context "anonymous user" do
    it "only searches all" do
      sign_in
      visit '/'
      expect(page).to have_content("All")
      expect(page).to have_css("a[data-search-label*=All]", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Works']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Collections']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Highlights']", visible: false)
      expect(page).not_to have_css("a[data-search-label*='My Shares']", visible: false)
      within('#search-form-header') do
        click_button("All")
        expect(page).to have_content("All of ScholarSphere")
        fill_in('search-field-header', with: subject_value)
        find("#search-submit-header").click
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(file1.title.first)
      expect(page).to have_content(file3.title.first)
      expect(page).to have_content(collection.title.first)
      expect(page).not_to have_content(file2.title.first)
      click_link(file1.title.first)
      expect(page).to have_link("Back to search results")
    end
  end
  context "known user" do
    before do
      sign_in_with_js(user)
      visit('/')
    end
    it "searches all" do
      expect(page).to have_content("All")
      expect(page).to have_css("a[data-search-label*=All]", visible: false)
      expect(page).to have_css("a[data-search-label*='My Works']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Collections']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Highlights']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Shares']", visible: false)
      within('#search-form-header') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(file1.title.first)
      expect(page).to have_content(file2.title.first)
      expect(page).to have_content(file3.title.first)
      expect(page).to have_content(collection.title.first)

      find("a[title=Gallery]").click
      expect(page).to have_content(file1.title.first)
      expect(page).to have_content(file2.title.first)
      expect(page).to have_content(file3.title.first)
      expect(page).to have_content(collection.title.first)
      # TODO: Collection icon? see #284
      # expect(page).to have_css("img.collection-icon")
      click_link(file1.title.first)
      expect(page).to have_link("Back to search results")
    end
    it "searches My Works" do
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Works")
      within('#search-form-header') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text: "Works")
      expect(page).to have_content(file1.title.first)
      expect(page).to have_content(file2.title.first)
      expect(page).not_to have_content(file3.title.first)
      expect(page).not_to have_css('#src_copy_link' + collection.id)
    end
    it "searches My Collections" do
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Collections")
      within('#search-form-header') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text: "Collections")
      expect(page).to have_content(collection.title.first)
      expect(page).not_to have_content(file1.title.first)
      expect(page).not_to have_content(file2.title.first)
      expect(page).not_to have_content(file3.title.first)
    end
  end
end
