require 'spec_helper'


describe 'catalog searching' do

  let(:user) { FactoryGirl.find_or_create(:jill) }


  before :each do
    @gf1 =  GenericFile.new.tap do |f|
      f.title = 'title 1'
      f.tag = ["tag1", "tag2"]
      f.apply_depositor_metadata('jilluser')
      f.save!
    end
    @gf2 =  GenericFile.new.tap do |f|
      f.title = 'title 2'
      f.tag = ["tag2", "tag3"]
      f.apply_depositor_metadata('jilluser')
      f.save!
    end
    @col =  Collection.new.tap do |f|
      f.title = 'title 3'
      f.tag = ["tag3", "tag4"]
      f.apply_depositor_metadata('jilluser')
      f.save!
    end
  end

  before do
    sign_in_as user
    visit '/'
  end

  it "finds multiple files" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag2")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@gf1.title.first)
    page.should have_content(@gf2.title.first)
    page.should_not have_content(@col.title)
  end

  it "finds files and collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag3")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@col.title)
    page.should have_content(@gf2.title.first)
    page.should_not have_content(@gf1.title.first)
  end

  it "finds collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag4")
      click_button("Go")
    end
    page.should have_content('Search Results')
    page.should have_content(@col.title)
    page.should_not have_content(@gf2.title.first)
    page.should_not have_content(@gf1.title.first)
  end
end
