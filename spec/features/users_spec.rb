require 'spec_helper'
require_relative 'feature_spec_helper'

describe "User Profile" do
  let(:admin_user) { create :administrator }

  let(:user_name) {admin_user.login}

  before do
    sign_in_as admin_user
    visit "/"
  end

  context "User with files" do
    let(:conn) { ActiveFedora::SolrService.instance.conn }
    before do
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

    it "should be displayed" do
      expect(page).to have_content "Edit Your Profile"
      expect(page).to have_content "Deposited Files 12"
    end
  end

  context "any user" do
    before do
      go_to_user_profile
    end

    it "should be editable", js:false do
      click_link "Edit Your Profile"
      fill_in 'user_twitter_handle', with: 'curatorOfData'
      click_button 'Save Profile'
      click_link 'Profile'
      expect(page).to have_content "Your profile has been updated"
      expect(page).to have_content "curatorOfData"
    end

    it "allows clicking on user information tab" do
      click_link "Profile"
      expect(page).to have_selector('li.active', text:"Profile")
      expect(page).to have_content(admin_user.title)
    end

    it "should display all users" do
      click_link "View Users"
      expect(page).to have_xpath("//td/a[@href='/users/#{admin_user.login}']")
    end

    it "should allow searching through all users" do
      @archivist = FactoryGirl.find_or_create(:archivist)
      click_link "View Users"
      expect(page).to have_xpath("//td/a[@href='/users/#{admin_user.login}']")
      expect(page).to have_xpath("//td/a[@href='/users/archivist1']")
      fill_in 'user_search', with: 'archivist1'
      click_button "user_submit"
      expect(page).not_to have_xpath("//td/a[@href='/users/#{admin_user.login}']")
      expect(page).to have_xpath("//td/a[@href='/users/archivist1']")
    end

    context "User with trophies" do
      let(:file1) {create_file admin_user, {title: 'file title'}}
      let!(:trophy) {Trophy.create! user_id: admin_user.id, generic_file_id: file1.noid}
      
      it "allows to view profile with trophies" do
        go_to_user_profile
        expect(page).to have_css '.active a', text:"Contributions"
        expect(page).to have_content file1.title.first
      end

    end

    context "User with proxy" do
      let (:u2) {FactoryGirl.create :random_user}
      
      before do
        u2.can_make_deposits_for << admin_user
        u2.save!
        go_to_user_profile
      end
      
      it "allows clicking on proxy tab" do
        click_link "Proxies"
        expect(page).to have_selector('li.active', text:"Proxies")
        expect(page).to have_content(u2.display_name)
      end
    end
    
    context  "user with activity" do
      let (:event_text) {"Text profile event"}
      let (:event) {admin_user.create_event(event_text, Time.now.to_i)}
      before do
        admin_user.log_profile_event(event)
        go_to_user_profile
      end

      it "allows clicking on activity tab" do
        click_link "Activity"
        expect(page).to have_selector('li.active', text:"Activity")
        expect(page).to have_content(event_text)
      end      
    end

  end
end