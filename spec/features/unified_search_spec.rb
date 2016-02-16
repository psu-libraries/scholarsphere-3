# frozen_string_literal: true
require 'feature_spec_helper'

describe 'unified search', type: :feature do
  let(:subject_value) { 'fffzzz' }
  let(:user)          { FactoryGirl.find_or_create(:jill) }
  let(:other_user)    { FactoryGirl.find_or_create(:archivist) }

  before do
    @gf1 = create_file user, title: 'title 1 abc', tag: [subject_value]
    @gf2 = create_file user, title: 'title 2 abc', tag: [subject_value], read_groups: ['private']
    @gf3 = create_file other_user, title: 'title 3 abc', tag: [subject_value]
    @collection = Collection.new.tap do |f|
      f.title = 'collection title abc'
      f.apply_depositor_metadata(user.login)
      f.description = subject_value
      f.read_groups = ['public']
      f.members = [@gf1, @gf2]
      f.save
    end
  end
  context "anonymous user" do
    it "only searches all" do
      sign_in
      visit '/'
      expect(page).to have_content("All")
      expect(page).to have_css("a[data-search-label*=All]", visible: false)
      expect(page).to_not have_css("a[data-search-label*='My Files']", visible: false)
      expect(page).to_not have_css("a[data-search-label*='My Collections']", visible: false)
      expect(page).to_not have_css("a[data-search-label*='My Highlights']", visible: false)
      expect(page).to_not have_css("a[data-search-label*='My Shares']", visible: false)
      within('#masthead_controls') do
        click_button("All")
        expect(page).to have_content("All of ScholarSphere")
        fill_in('search-field-header', with: subject_value)
        find("#search-submit-header").click
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(@gf1.title.first)
      expect(page).to have_content(@gf3.title.first)
      expect(page).to have_content(@collection.title)
      expect(page).to_not have_content(@gf2.title.first)
      click_link(@gf1.title.first)
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
      expect(page).to have_css("a[data-search-label*='My Files']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Collections']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Highlights']", visible: false)
      expect(page).to have_css("a[data-search-label*='My Shares']", visible: false)
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_content('Search Results')
      expect(page).to have_content(@gf1.title.first)
      expect(page).to have_content(@gf2.title.first)
      expect(page).to have_content(@gf3.title.first)
      expect(page).to have_content(@collection.title)

      # TODO: Gallery view no longer available? see #9679
      # find("a[title=Gallery]").click
      expect(page).to have_content(@gf1.title.first)
      expect(page).to have_content(@gf2.title.first)
      expect(page).to have_content(@gf3.title.first)
      expect(page).to have_content(@collection.title)
      expect(page).to have_css("img.collection-icon")
      click_link(@gf1.title.first)
      expect(page).to have_link("Back to search results")
    end
    it "searches My Files" do
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Files")
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text: "Files")
      expect(page).to have_content(@gf1.title.first)
      expect(page).to have_content(@gf2.title.first)
      expect(page).to_not have_content(@gf3.title.first)
      expect(page).to_not have_css('#src_copy_link' + @collection.id)
    end
    it "searches My Collections" do
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Collections")
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text: "Collections")
      expect(page).to have_content(@collection.title)
      expect(page).to_not have_content(@gf1.title.first)
      expect(page).to_not have_content(@gf2.title.first)
      expect(page).to_not have_content(@gf3.title.first)
    end
  end
end
