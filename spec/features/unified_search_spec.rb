require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }
describe_options[:js] = true if ENV['JS']

describe 'unified search', describe_options do

  describe 'all files' do
    let(:subject_value) { 'fffzzz' }

    before(:each) do
      @gf1 =  GenericFile.new.tap do |f|
        f.title = 'title 1 abc'
        f.apply_depositor_metadata('jilluser')
        f.tag = subject_value
        f.read_groups = ['public']
        f.save
      end
      @gf2 =  GenericFile.new.tap do |f|
        f.title = 'title 2 abc'
        f.tag = subject_value
        f.apply_depositor_metadata('jilluser')
        f.save
      end
      @gf3 =  GenericFile.new.tap do |f|
        f.title = 'title 3 abc'
        f.apply_depositor_metadata('otheruser')
        f.tag = subject_value
        f.read_groups = ['public']
        f.save
      end
      @collection =  Collection.new.tap do |f|
        f.title = 'collection title abc'
        f.apply_depositor_metadata('jilluser')
        f.description = subject_value
        f.read_groups = ['public']
        f.members = [@gf1, @gf2]
        f.save
      end
    end
    context "anonymous user" do
      it "only searches all" do
        visit '/'
        expect(page).to have_content("All")
        expect(page).to have_css("a[data-search-label*=All]", visible:false)
        expect(page).to_not have_css("a[data-search-label*='My Files']", visible:false)
        expect(page).to_not have_css("a[data-search-label*='My Collections']", visible:false)
        expect(page).to_not have_css("a[data-search-label*='My Highlights']", visible:false)
        expect(page).to_not have_css("a[data-search-label*='My Shares']", visible:false)
        within('#masthead_controls') do
          fill_in('search-field-header', with: subject_value)
          click_button("Go")
        end
        expect(page).to have_content('Search Results')
        expect(page).to have_content(@gf1.title.first)
        expect(page).to have_content(@gf3.title.first)
        expect(page).to have_content(@collection.title)
        expect(page).to_not have_content(@gf2.title.first)
      end
    end
    context "known user" do
      it "searches all" do
        login_js
        visit '/'
        expect(page).to have_content("All")
        expect(page).to have_css("a[data-search-label*=All]", visible:false)
        expect(page).to have_css("a[data-search-label*='My Files']", visible:false)
        expect(page).to have_css("a[data-search-label*='My Collections']", visible:false)
        expect(page).to have_css("a[data-search-label*='My Highlights']", visible:false)
        expect(page).to have_css("a[data-search-label*='My Shares']", visible:false)
        within('#masthead_controls') do
          fill_in('search-field-header', with: subject_value)
          click_button("Go")
        end
        expect(page).to have_content('Search Results')
        expect(page).to have_content(@gf1.title.first)
        expect(page).to have_content(@gf2.title.first)
        expect(page).to have_content(@gf3.title.first)
        expect(page).to have_content(@collection.title)
      end
    end
    it "searches My Files" do
      login_js
      visit '/'
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Files")
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text:"Files")
      expect(page).to have_content(@gf1.title.first)
      expect(page).to have_content(@gf2.title.first)
      expect(page).to_not have_content(@gf3.title.first)
      expect(page).to_not have_content(@collection.title)
    end
    it "searches My Collections" do
      login_js
      visit '/'
      expect(page).to have_content("All")
      click_on("All")
      click_on("My Collections")
      within('#masthead_controls') do
        fill_in('search-field-header', with: subject_value)
        click_button("Go")
      end
      expect(page).to have_selector('li.active', text:"Collections")
      expect(page).to have_content(@collection.title)
      expect(page).to_not have_content(@gf1.title.first)
      expect(page).to_not have_content(@gf2.title.first)
      expect(page).to_not have_content(@gf3.title.first)
    end
  end
end
