require 'spec_helper'

describe "Showing the Generic File", :type => :feature do
  let(:current_user) { create :administrator }
  let!(:gf) { create_file current_user, {title: 'file title'} }

  before do
    sign_in_as current_user
    visit "/"
    click_link "Recent Additions"
    expect(page).to have_content(gf.title.first)
    click_link gf.title.first
    expect(page).to have_content("Descriptions")
  end

  it "allows a feature to be marked and deleted" do
    expect(page).to have_link "Feature"
    click_link "Feature"
    expect(page).to have_content("Featured")
    visit '/'
    within(".new_featured_work_list") do
      expect(page).to have_content(gf.title[0])
      find(".glyphicon-remove").click
    end
    within(".new_featured_work_list") do
      expect(page).not_to have_content(gf.title[0])
    end
  end
end
