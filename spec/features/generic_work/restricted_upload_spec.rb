# frozen_string_literal: true

require 'feature_spec_helper'

describe GenericWork, type: :feature do
  include Selectors::Dashboard

  context 'when restricting total upload size' do
    let(:current_user) { create(:user) }

    before do
      Rails.application.config.upload_limit = '30'
      sign_in_with_named_js(:restricted_upload, current_user, disable_animations: true)
      visit('/concern/generic_works/new')
    end

    after { Rails.application.config.upload_limit = '1000000' }

    it 'prevents submitting the form' do
      # Verify file requirement is not met and no limit error is shown
      click_on 'Files'
      expect(page).to have_selector('#sizealert', visible: false)
      within('#required-files') do
        expect(page).to have_link('Add files')
      end
      expect(page).to have_content('Total size for all combined files is restricted to 30 Bytes.')

      # Attach a file larger than the limit
      attach_file('inputfiles', test_file_path('readme.md'), visible: false)
      check 'agreement'
      click_on 'Upload all local files'
      sleep(5)

      # Verify error messages
      expect(page).to have_selector('#sizeprogress', text: '133%')
      expect(page).to have_selector('#sizealert', text: 'Selected size exceeds the maximum allowed for upload',
                                                  visible: true)
      within('#required-files') do
        expect(page).to have_link('Add files')
      end

      # Delete and add smaller file
      click_on 'Delete'
      sleep(2)
      expect(page).to have_selector('#sizealert', visible: false)
      within('#required-files') do
        expect(page).to have_link('Add files')
      end
      attach_file('inputfiles', test_file_path('little_file.txt'), visible: false)
      click_on 'Upload all local files'
      sleep(5)

      # Verify file requirement is met and no errors are present
      expect(page).to have_selector('#sizeprogress', text: '20%')
      expect(page).to have_selector('#sizealert', visible: false)
      within('#required-files') do
        expect(page).to have_link('Required files complete')
      end
    end
  end
end
