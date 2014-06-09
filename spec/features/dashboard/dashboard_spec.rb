require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'The Dashboard' do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard
  end

  it "shows the user's statistics" do
    page.should have_content("Your Statistics")
    page.should have_content("Files you've deposited into Sufia")
    page.should have_content("People you follow")
    page.should have_content("People who are following you")
  end

  it "displays information about the user" do
    page.should have_content "Joe Example"
    page.should have_link "View Profile"
    page.should have_link "Edit Profile"
  end

  it "shows recent activity" do
    page.should have_content "User Activity"
    page.should have_content "User has no recent activity"
  end

  it "lists any recent notificaitons" do
    page.should have_content "User Notifications"
    page.should have_content "User has no notifications"
  end

end
