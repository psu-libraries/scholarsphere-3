require 'spec_helper'
require_relative 'feature_spec_helper'

describe "User Profile", :type => :feature do
  let(:admin_user) { create :administrator }

  let(:user_name) { admin_user.login }

  let!(:archivist) { create :archivist }

  before do
    sign_in_as admin_user
    visit "/"
  end

  context "any user" do
    let(:conn) { ActiveFedora::SolrService.instance.conn }
    let(:file1) {create_file admin_user, {title: 'file title'}}
    let!(:trophy) {Trophy.create! user_id: admin_user.id, generic_file_id: file1.noid}
    let (:event_text) {"Text profile event"}
    let (:event) {admin_user.create_event(event_text, Time.now.to_i)}
    let (:u2) {FactoryGirl.create :random_user}

    before do
      admin_user.log_profile_event(event)
      u2.can_make_deposits_for << admin_user
      u2.save!
      # More than 10 times, because the pagination threshold is 10
      12.times do |t|
        conn.add  id: "199#{t}", Solrizer.solr_name('depositor', :stored_searchable) => user_name
      end
      conn.commit
      go_to_user_profile
    end

    after do
      12.times do |t|
        conn.delete_by_id "199#{t}"
      end
      conn.commit
    end

    it "allows interaction", js:false do

      #allows viewing follow and following modal
      click_link "Follower(s):"
      expect(page).to have_content I18n.t("sufia.user_profile.no_followers")
      click_on "Close"
      expect(page).not_to have_content I18n.t("sufia.user_profile.no_followers")
      click_link "Following"
      expect(page).to have_content I18n.t("sufia.user_profile.no_following")
      click_on "Close"
      expect(page).not_to have_content I18n.t("sufia.user_profile.no_following")

      #allows to view profile with trophies
      expect(page).to have_css '.active a', text:"Contributions"
      expect(page).to have_content file1.title.first

      #allows clicking on activity tab
      click_link "Activity"
      expect(page).to have_selector('li.active', text:"Activity")
      expect(page).to have_content(event_text)

      #allows clicking on proxy tab
      click_link "Proxies"
      expect(page).to have_selector('li.active', text:"Proxies")
      expect(page).to have_content(u2.display_name)

      # allows clicking on user information tab
      click_link "Profile"
      expect(page).to have_selector('li.active', text:"Profile")
      expect(page).to have_content(admin_user.title)

      # Edit profile
      click_link "Edit Your Profile"
      fill_in 'user_twitter_handle', with: 'curatorOfData'
      click_button 'Save Profile'
      click_link 'Profile'
      expect(page).to have_content "Your profile has been updated"
      expect(page).to have_content "curatorOfData"

      # displays other users
      click_link "View Users"
      expect(page).to have_xpath("//td/a[@href='/users/#{admin_user.login}']")

      # should allow searching through all users
      expect(page).to have_xpath("//td/a[@href='/users/archivist1']")
      fill_in 'user_search', with: 'archivist1'
      click_button "user_submit"
      expect(page).not_to have_xpath("//td/a[@href='/users/#{admin_user.login}']")
      expect(page).to have_xpath("//td/a[@href='/users/archivist1']")

    end


    #todo refactor tests to run in one loop for timing
    #todo add test for follow following
  end
end