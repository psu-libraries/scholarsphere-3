require_relative './feature_spec_helper'

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

    let (:file) { GenericFile.first }
    context "Transferring the file to someone else" do
      before do
        within "#document_#{file.noid}" do
          caret = find ".dropdown-toggle"
          caret.click
        end
        click_link "Transfer Ownership of File"

        fill_in "User", with: new_owner.user_key
        fill_in "Comments", with: "File transfer comments"
        within ".form-actions" do
          click_button "Transfer"
        end
      end
      pending "Creates a proxy_deposit_request" do
        p = ProxyDepositRequest.first
        p.receiving_user.should == new_owner  
      end
    end
  end
end
