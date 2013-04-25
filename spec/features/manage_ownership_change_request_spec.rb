require 'spec_helper'

feature "Managing ownership change requests" do
  background do
    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
  end
  context "when someone has request to transfer a file to me" do
    background do
      sender = FactoryGirl.find_or_create(:test_user_1)
      @file = GenericFile.new
      @file.apply_depositor_metadata(sender.user_key)
      @file.save!
      @file.request_transfer_to(@user)
    end

    scenario "then I should be able to accept it" do
      visit '/'
      click_link "transfer files"
      within("#incoming-transfers") do
        click_button "Accept"
      end
      page.should have_content("Transfer complete") 
    end

    scenario "then I should be able to reject it" do
      visit '/dashboard/proxy' 
    end
  end
  context "when I have requested to transfer a file to someone else" do
    scenario "then I should be able to cancel the request" do
      visit '/dashboard/proxy' 
    end
    scenario "then I should be able to see the status of requests" do
      visit '/dashboard/proxy' 
    end
  end
end
