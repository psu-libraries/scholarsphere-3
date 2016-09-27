# frozen_string_literal: true
require 'feature_spec_helper'

describe "User Profile", type: :feature do
  let!(:admin_user) { create(:administrator, :with_event, event: event_text) }
  let!(:archivist)  { create(:archivist) }
  let!(:file1)      { create(:trophy_file, depositor: admin_user.login) }
  let!(:u2)         { create(:random_user, :with_proxy, proxy_for: admin_user) }

  let(:event_text)  { "Text profile event" }

  context "with any user" do
    specify do
      sign_in_with_js(admin_user)
      visit("/users/#{admin_user}")

      # allows to view profile with trophies
      expect(page).to have_css '.active a', text: "Highlighted"
      expect(page).to have_content file1.title.first

      # allows clicking on activity tab
      click_link "Activity"
      expect(page).to have_selector('li.active', text: "Activity")
      expect(page).to have_content(event_text)

      # allows editing the user's profile
      click_link "Edit Your Profile"
      fill_in 'user_twitter_handle', with: 'curatorOfData'
      fill_in 'user_orcid', with: '0000-0000-0000-0000'
      click_button 'Save Profile'
      expect(page).to have_content "Your profile has been updated"
      expect(page).to have_content "curatorOfData"
      expect(page).to have_content "0000-0000-0000-0000"

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
  end
end
