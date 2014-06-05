require_relative './feature_spec_helper'

describe "Featured works on the home page" do
  let!(:admin_user) { create :administrator }
  let!(:file) { create_file admin_user, {title:'file title'} }
  let!(:featured_work) { FeaturedWork.create!(generic_file_id: file.noid) }

  before do
    sign_in_as admin_user
    visit "/"
  end

  it "appears as a featured work", js:true do
    page.should have_content "Featured Works"
    within("#featured_container") do
      page.should have_content(file.title[0])
    end
  end

  it "appears as a recently uploaded file" do
    click_link "Recently Uploaded"
    within("#recently_uploaded") do
      page.should have_content(file.title[0])
    end
  end

  it "allows the user to remove it as a featured work" do
    page.should have_css ".glyphicon-remove"
    find(".glyphicon-remove").click
    within("#featured_container") do
      page.should_not have_content(file.title[0])
    end
  end
end
