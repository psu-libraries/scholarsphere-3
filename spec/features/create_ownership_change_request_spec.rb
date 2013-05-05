require 'spec_helper'

feature "Creating ownership change requests" do
  let(:user) { FactoryGirl.find_or_create(:user)}
  let(:another_user) { FactoryGirl.find_or_create(:test_user_1)}

  background do
    sign_in user
  end
  after(:all) do
    GenericFile.find(:all).each(&:delete)
  end
  context "when I have a file on my dashboard" do
    background do
      GenericFile.new.tap do |f|
        f.apply_depositor_metadata(user.user_key)
        f.save!
      end
    end

    scenario "then I should be able to transfer it" do
      visit '/'
      click_link "dashboard"
      click_link "Transfer Ownership of File"

      fill_in "User", with: another_user.user_key
      fill_in "Comments", with: "Just a few comments for my friends"
      click_button "Transfer"
    end
  end
end
