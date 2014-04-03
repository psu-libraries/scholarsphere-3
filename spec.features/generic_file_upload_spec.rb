require_relative './feature_spec_helper'

describe "Generic File uploading and downloading:", request: true do

  context "When logged in as a PSU user" do
    let(:current_user) { create(:user) }
    let(:filename) { 'world.png' }

    before do
      sign_in_as current_user
    end

    specify "I can upload a file successfully" do
      visit new_generic_file_path
      check "terms_of_service"
      attach_file("files[]", test_file_path(filename))
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

  context "When logged in as a non-PSU user" do
    let(:current_user) { create(:non_psu_user)}

    before do
      sign_in_as current_user
    end

    specify "I can't get to the upload page" do
      visit new_generic_file_path
      page.should have_content 'Unauthorized'
      page.should_not have_content 'Upload'
    end
  end
end
