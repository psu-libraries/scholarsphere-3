require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Collections:', :type => :feature do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard
    click_link("Create Collection")
    create_collection ["My collection"], current_user, ["Personal collection of great things"]
    go_to_dashboard_collections
  end

  specify 'tab title and buttons' do
    expect(page).to have_content("My Collections")
    within('#sidebar') do
      expect(page).to have_content("Upload")
      expect(page).to have_content("Create Collection")
    end
    expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
  end

  specify 'collections are displayed in the Collections list' do
    expect(page).to have_content "My collection"
  end

  specify 'toggle displays additional information' do
    first('i.glyphicon-chevron-right').click
    expect(page).to have_content("Personal collection of great things")
    expect(page).to have_content(current_user)
  end

  specify 'additional information is hidden' do
    expect(page).not_to have_content("Personal collection of great things")
    expect(page).not_to have_content(current_user)
  end
  
  specify "toggle addtitional actions" do
    expect(page).not_to have_content("Edit Collection")
    expect(page).not_to have_content("Delete Collection")
    within('#documents') do
      first('.dropdown-toggle').click
    end
    expect(page).to have_content("Edit Collection")
    expect(page).to have_content("Delete Collection")
  end

  specify 'collections are not displayed in the File list' do
    go_to_dashboard_files
    expect(page).not_to have_content "My collection"
  end

  describe 'facets,' do
    specify "displays the correct totals for each facet" do
      within("#facets") do
        click_link('Object Type')
        expect(page).to have_content('Collection (1)')
        click_link('Creator')
        expect(page).to have_content("#{current_user} (1)")
      end
    end
  end

end
