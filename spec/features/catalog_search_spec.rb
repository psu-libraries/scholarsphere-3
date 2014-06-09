require_relative './feature_spec_helper'


describe 'catalog searching' do

  let(:user) { create :jill }
  let!(:gf1) { create_file user, {title:'title 1', tag:["tag1", "tag2"]} }
  let!(:gf2) { create_file user, {title:'title 2', tag:["tag2", "tag3"]} }
  let!(:gf3) { create_file user, {title:'title 3', tag:["tag3", "tag4"]} }
  let!(:collection) do
    Collection.new.tap do|col|
      col.apply_depositor_metadata(user.user_key)
      col.title = "collection title"
      col.tag = ["tag3","tag4"]
      col.save!
    end
  end

  before do
    sign_in_as user
    visit '/'
  end

  it "shows the facets" do
    within('#masthead_controls') do
      click_button("Go")
    end
    expect(page).to have_css "div#facets"
  end

  it "finds multiple files" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag2")
      click_button("Go")
    end
    expect(page).to have_content('Search Results')
    expect(page).to have_content(gf1.title.first)
    expect(page).to have_content(gf2.title.first)
    expect(page).not_to have_content(collection.title)
  end

  it "finds files and collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag3")
      click_button("Go")
    end
    expect(page).to have_content('Search Results')
    expect(page).to have_content(collection.title)
    expect(page).to have_content(gf2.title.first)
    expect(page).not_to have_content(gf1.title.first)
  end

  it "finds collections" do
    within('#masthead_controls') do
      fill_in('search-field-header', with: "tag4")
      click_button("Go")
    end
    expect(page).to have_content('Search Results')
    expect(page).to have_content(collection.title)
    expect(page).not_to have_content(gf2.title.first)
    expect(page).not_to have_content(gf1.title.first)
  end
end
