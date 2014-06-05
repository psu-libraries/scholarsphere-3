require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:' do

  context 'When logged in as a PSU user' do
    let!(:current_user) { create :user }
    let(:filename) { 'world.png' }
    let(:file) { find_file_by_title "world.png" }

    before do
      sign_in_as current_user
    end

    context 'user needs help' do
      before do
        visit new_generic_file_path
        check 'terms_of_service'
        attach_file 'files[]', test_file_path(filename)
        click_button 'main_upload_start'
        page.should have_content 'Apply Metadata'
      end

      specify 'I can view the help modals' do
        page.should have_css('#rightsModal.modal[aria-hidden*="true"]', visible: false)
        click_link('License Descriptions')
        sleep(1) #TODO this should be something better than a sleep
        page.should have_content('ScholarSphere License Descriptions')
        click_on('Close')
        sleep(1) #TODO this should be something better than a sleep
        page.should_not have_content('ScholarSph7ere License Descriptions')
        page.should have_css('#rightsModal', visible: false)
        click_link("What's this")
        sleep(1) #TODO this should be something better than a sleep
        page.should have_content('ScholarSphere Permissions')
        click_on('Close')
        sleep(1) #TODO this should be something better than a sleep
        page.should_not have_content('ScholarSphere Permissions')
        page.should have_css('#myModal', visible: false)
        page.should have_css('#myModal.modal[aria-hidden*="true"]', visible: false)
      end

    end
    context 'user does not need help' do
      before do
        upload_generic_file filename
      end

      specify 'I can upload a file successfully' do
        page.should have_css '#documents'
        page.should have_content filename
      end

      specify 'I can delete an uploaded file' do
        page.should have_content file.title.first
        db_item_actions_toggle(file).click
        click_link 'Delete File'
        page.should_not have_content file.title.first
    end
    end
  end

  context 'When logged in as a non-PSU user' do
    let!(:current_user) { create :non_psu_user }

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
