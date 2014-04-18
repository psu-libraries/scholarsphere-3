require_relative './feature_spec_helper'

include Selectors::Header
include Selectors::Dashboard
include Selectors::NewTransfers
include Selectors::Transfers

describe "Transferring file ownership" do

  let(:original_owner) { create(:user, display_name: 'Original Owner') }
  let(:new_owner) { create(:user, display_name: 'New Owner') }

  before do
    sign_in_as original_owner
    upload_generic_file 'world.png'
  end

  describe "When I request a file transfer" do
    let (:file) { GenericFile.last }

    context "To myself" do
      before { transfer_ownership_of_file(file, original_owner) }
      it "Displays an appropriate error message" do
        page.should have_content 'Sending user must specify another user to receive the file'
      end
    end

    context "To someone else" do
      before { transfer_ownership_of_file(file, new_owner) }
      it "Creates a transfer request" do
        page.should have_content 'Transfer request created'
      end
      context "If the new owner accepts it" do
        before do
          new_owner.proxy_deposit_requests.last.transfer!
          find('.dropdown-toggle.btn.btn-default').click
          click_link 'transfer requests'
        end
        specify "I should see it was accepted" do
          page.find('#outgoing-transfers').should have_content('Accepted')
        end
      end
      context "If I cancel it" do
        before do
          user_utility_toggle.click
          click_link 'transfer requests'
          first_sent_cancel_button.click
        end
        specify "I should see it was cancelled" do
          page.should have_content('Transfer canceled')
        end
      end
    end
  end

  describe "When someone requests a file transfer to me" do
    let (:file) { GenericFile.last }
    before do
      # As the original_owner, transfer a file to the new_owner
      transfer_ownership_of_file(file, new_owner)
      # Become the new_owner so we can manage transfers sent to us
      sign_in_as new_owner
      # Remove the session cookie for the original_owner
      # to ensure we visit pages that belong to the new_owner
      page.driver.browser.remove_cookie '_scholarsphere_secure_session'
      visit '/dashboard'
      user_utility_toggle.click
      click_link 'transfer requests'
      page.should have_content 'Transfer of Ownership'
    end
    specify "I should receive a notification" do
      user_notifications_link.click
      page.should have_content "#{original_owner.name} wants to transfer a file to you"
    end
    specify "I should be able to accept it" do
      first_received_accept_dropdown.click
      click_link 'Allow depositor to retain edit access'
      page.should have_content('Transfer complete')
    end
    specify "I should be able to reject it" do
      first_received_reject_button.click
      page.should have_content('Transfer rejected')
    end
  end

  def transfer_ownership_of_file(file, new_owner)
    file_actions_toggle(file.noid).click
    click_link 'Transfer Ownership of File'
    new_owner_dropdown.click
    new_owner_search_field.set(new_owner.user_key)
    new_owner_search_result.click
    fill_in 'proxy_deposit_request[sender_comment]', with: 'File transfer comments'
    submit_button.click
  end
end
