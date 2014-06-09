require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Collections:' do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard
    click_link("Create Collection")
    create_collection("My collection", current_user, "Personal collection of great things")
    go_to_dashboard_collections
  end

  specify 'collections are displayed in the Collections list' do
    page.should have_content "My collection"
  end

  specify 'toggle displays additional information' do
    first('i.glyphicon-plus').click
    page.should have_content("Personal collection of great things")
    page.should have_content(current_user)
  end

  specify 'additional information is hidden' do
    page.should_not have_content("Personal collection of great things")
    page.should_not have_content(current_user)
  end
  
  specify "toggle addtitional actions" do
    page.should_not have_content("Edit Collection")
    page.should_not have_content("Delete Collection")
    first('span.glyphicon-chevron-down').click
    page.should have_content("Edit Collection")
    page.should have_content("Delete Collection")
  end

  specify 'collections are not displayed in the File list' do
    go_to_dashboard_files
    page.should_not have_content "My collection"
  end

  describe 'facets,' do
    specify "displays the correct totals for each facet" do
      within("#facets") do
        click_link('Object Type')
        page.should have_content('Collection (1)')
        click_link('Creator')
        page.should have_content("#{current_user} (1)")
      end
    end
  end

end
