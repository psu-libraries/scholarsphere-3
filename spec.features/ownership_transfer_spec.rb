require_relative './feature_spec_helper'

include Selectors::NewTransfers
include Selectors::Dashboard

describe "Sending a transfer" do

  let(:original_owner) { create(:user) }
  let(:new_owner) { create(:user) }

  before do
    sign_in_as original_owner
  end

  context "Given I've successfully uploaded a file" do
    before do
      upload_generic_file 'world.png'
    end

    let (:file) { GenericFile.last }

    context "Transferring the file to someone else" do
      before do
        transfer_ownership_of_file(file, new_owner)
      end

      it "Creates a transfer request" do
       page.should have_content "Transfer request created"
      end
    end

    context "Transferring the file to myself" do
      before do
        transfer_ownership_of_file(file, original_owner)
      end

      it "Displays an appropriate error message" do
       page.should have_content "Sending user must specify another user to receive the file"
      end
    end
  end

  def transfer_ownership_of_file(file, new_owner)
    file_actions_toggle(file.noid).click
    click_link "Transfer Ownership of File"
    new_owner_dropdown.click
    new_owner_search_field.set(new_owner.user_key)
    new_owner_search_result.click
    fill_in "proxy_deposit_request[sender_comment]", with: "File transfer comments"
    submit_button.click
  end
end
