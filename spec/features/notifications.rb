require 'spec_helper'

describe "Notifications page", {type: :feature} do

  before do
    login_as :user_with_fixtures
  end

  it "should list notifications with date, subject and message" do
    visit "/notifications"
    validate_user_notifications
  end

  it "should list the most recent notifications in the user's dashboard" do
    go_to_dashboard
    validate_user_notifications
  end

  def validate_user_notifications
    page.should have_content "User Notifications"
    page.find(:xpath, '//thead/tr').should have_content "Date"
    page.find(:xpath, '//thead/tr').should have_content "Subject"
    page.find(:xpath, '//thead/tr').should have_content "Message"
    page.should have_content "Sample notification."
    page.should have_content "less than a minute ago"
    page.should have_content "You've got mail."
  end

end
