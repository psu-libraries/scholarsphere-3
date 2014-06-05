require 'spec_helper'

describe "User Profile" do
  let(:admin_user) { create :administrator }

  let(:user_name) {admin_user.login}
  let(:conn) { ActiveFedora::SolrService.instance.conn }
  before do
    # More than 10 times, because the pagination threshold is 10
    12.times do |t|
      conn.add  id: "199#{t}", Solrizer.solr_name('depositor', :stored_searchable) => user_name
    end
    conn.commit
  end
  after do
    12.times do |t|
      conn.delete_by_id "199#{t}"
    end
    conn.commit
  end

  before do
    sign_in_as admin_user

    visit "/"
    click_link admin_user.display_name
  end

  it "should be displayed" do
    page.should have_content "Edit Your Profile"
    page.should have_content "Deposited Files 12"
  end

  it "should be editable", js:false do
    click_link "Edit Your Profile"
    fill_in 'user_twitter_handle', with: 'curatorOfData'
    click_button 'Save Profile'
    click_link 'Profile'
    page.should have_content "Your profile has been updated"
    pending "Tabs on profile do not work so we can not get to the profile tab.  Remove pending once this is closed: https://github.com/projecthydra/sufia/issues/514"
    page.should have_content "curatorOfData"
  end

  it "should display all users" do
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/#{admin_user.login}']")
  end

  it "should allow searching through all users" do
    @archivist = FactoryGirl.find_or_create(:archivist)
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/#{admin_user.login}']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
    fill_in 'user_search', with: 'archivist1'
    click_button "user_submit"
    page.should_not have_xpath("//td/a[@href='/users/#{admin_user.login}']")
    page.should have_xpath("//td/a[@href='/users/archivist1']")
  end

  context "User with trophies" do
    let(:file1) {create_file admin_user, {title: 'file title'}}
    let!(:trophy) {Trophy.create! user_id: admin_user.id, generic_file_id: file1.noid}

    it "allows to view profile with trophies" do
      #revisiting the page to show the new trophy
      click_link admin_user.display_name

      page.should have_css '.active a', text:"Contributions"
      page.should have_content file1.title.first
    end

  end
end