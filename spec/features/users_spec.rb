require 'spec_helper'

describe "User Profile" do

  before do
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    visit "/"
    click_link "curator1"
  end

  it "should be displayed" do
    page.should have_content "Edit Your Profile"
  end

  it "should be editable" do
    click_link "Edit Your Profile"
    fill_in 'user_twitter_handle', with: 'curatorOfData'
    click_button 'Save Profile'
    page.should have_content "Your profile has been updated"
    page.should have_content "curatorOfData"
  end

  it "should display all users" do
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1']")
  end

  it "should allow searching through all users" do
    @archivist = FactoryGirl.find_or_create(:archivist)
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
    fill_in 'user_search', with: 'archivist1'
    click_button "user_submit"
    page.should_not have_xpath("//td/a[@href='/users/curator1']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
  end
end
