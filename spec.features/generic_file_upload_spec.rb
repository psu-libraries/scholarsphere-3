require_relative './feature_spec_helper'

describe "Generic File uploading and downloading", request: true do

  context "when logged in as an LDAP user" do
    let(:current_user) { create(:user) }
    let(:filename) { 'world.png' }

    before do
      sign_in_as current_user
    end

    it "Uploads successfully" do
      visit new_generic_file_path
      check "terms_of_service"
      test_file_path = Rails.root.join("spec/fixtures/#{filename}").to_s
      attach_file("files[]", test_file_path)
      click_button 'main_upload_start'
      page.should have_content 'Apply Metadata'
      fill_in 'generic_file_tag', with: 'test_generic_file_tag'
      fill_in 'generic_file_creator', with: 'test_generic_file_creator'
      select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
      click_on 'upload_submit'
      page.should have_content 'My Dashboard'
      page.should have_content filename
    end
  end
end
