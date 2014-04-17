require_relative './feature_spec_helper'

describe "Generic File uploading and downloading:" do

  context "When logged in as a PSU user" do
    let(:current_user) { create(:user) }
    let(:filename) { 'world.png' }

    before do
      sign_in_as current_user
    end

    specify "I can upload a file successfully" do
      upload_generic_file(filename)
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
