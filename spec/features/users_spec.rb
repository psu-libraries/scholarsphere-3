require 'spec_helper'

describe "User Profile" do

  before do
    sign_in :curator
    visit "/"
  end

  it "should be displayed" do
    click_link "curator1"
    page.should have_content "Edit Your Profile"
  end

  it "should be editable" do
    click_link "curator1"
    click_link "Edit Your Profile"
    fill_in 'user_twitter_handle', with: 'curatorOfData'
    click_button 'Save Profile'
    page.should have_content "Your profile has been updated"
    page.should have_content "curatorOfData"
  end

  it "should display all users" do
    click_link "curator1"
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1']")
  end

  it "should allow searchin through all users" do
    @archivist = FactoryGirl.find_or_create(:archivist)
    click_link "curator1"
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
    fill_in 'user_search', with: 'archivist1'
    click_button "user_submit"
    page.should_not have_xpath("//td/a[@href='/users/curator1']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
  end
end
