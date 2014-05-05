require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:' do

  context 'When logged in as a PSU user' do
    let(:current_user) { create :user }
    let(:filename) { 'world.png' }
    let(:file) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"world.png").first }

    before do
      sign_in_as current_user
      upload_generic_file filename
    end

    specify 'I can upload a file successfully' do
      page.should have_content 'My Dashboard'
      page.should have_content filename
    end

    specify 'I can delete an uploaded file' do
      page.should have_content file.title.first
      db_item_actions_toggle(file).click
      click_link 'Delete File'
      page.should_not have_content file.title.first
    end
  end

  context 'When logged in as a non-PSU user' do
    let(:current_user) { create :non_psu_user }

    before do
      sign_in_as current_user
    end

    specify 'I cannot access the upload page' do
      visit new_generic_file_path
      page.should have_content 'Unauthorized'
      page.should_not have_content 'Upload'
    end
  end
end
