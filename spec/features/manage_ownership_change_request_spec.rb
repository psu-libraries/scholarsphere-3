require 'spec_helper'

feature "Managing ownership change requests" do
  background do
    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
  end
  after(:all) do
    GenericFile.destroy_all
    Collection.destroy_all
  end
  context "when someone has request to transfer a file to me" do
    background do
      sender = FactoryGirl.find_or_create(:test_user_1)
      @file = GenericFile.new.tap do |f|
        f.apply_depositor_metadata(sender.user_key)
        f.save!
        f.request_transfer_to(@user)
      end
    end

    scenario "then I should be able to accept it" do
      visit '/'
      click_link "transfer requests"
      click_link "Allow depositor to retain edit access"
      page.should have_content("Transfer complete")
    end

    scenario "then I should be able to reject it" do
      visit '/'
      click_link "transfer requests"
      within("#incoming-transfers") do
        click_button "Reject"
      end
      page.should have_content("Transfer rejected")
    end
  end
  context "when I have requested to transfer a file to someone else" do
    background do
      @receiver = FactoryGirl.find_or_create(:test_user_1)
      @file = GenericFile.new.tap do |f|
        f.apply_depositor_metadata(@user.user_key)
        f.save!
        f.request_transfer_to(@receiver)
      end
    end

    scenario "then I should be able to cancel the request" do
      visit '/'
      click_link "transfer requests"
      within("#outgoing-transfers") do
        click_button "Cancel"
      end
      page.should have_content("Transfer canceled")
    end

    context "and it has been accepted" do
      background do
        @receiver.proxy_deposit_requests.first.transfer!
      end
      scenario "then I should be able to see the status of requests" do
        visit '/'
        click_link "transfer requests"
        page.find('#outgoing-transfers').should have_content("Accepted")
      end
    end
  end
end
