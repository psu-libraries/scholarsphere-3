# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Generic File batch uploading', type: :feature, js: true do
  context 'when logged in as a PSU user' do
    let(:current_user)          { create(:user) }
    let(:other_user)            { create(:user) }
    let(:filename)              { 'little_file.txt' }
    let(:batch)                 { ['little_file.txt', 'little_file.txt'] }
    let(:file)                  { work }
    let(:work)                  { find_work_by_title 'little_file.txt_title' }

    before { login_as(current_user) }

    describe 'uploading a new work' do
      it 'enforces a workflow' do
        Sufia::AdminSetCreateService.create_default!
        visit '/batch_uploads/new?payload_concern=GenericWork'

        within('form#new_batch_upload_item') { expect(page).to have_selector('input#batch_upload_item_payload_concern', visible: false) }

        click_on 'Files'
        attach_file('inputfiles', test_file_path(filename), visible: false)
        expect(page).to have_content('Start')
        click_on 'Start'
        expect(page).to have_content('Required files complete')

        click_on 'Metadata'
        fill_in 'batch_upload_item_keyword', with: 'keyword'
        fill_in 'batch_upload_item_description', with: 'My description'
        select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'batch_upload_item_rights'

        within('div#savewidget') { expect(page).to have_link('Required metadata complete') }
        check 'agreement'
        click_on 'Save'
        expect(page).to have_content('Your files are being processed by ScholarSphere in the background. The metadata and access controls you specified are being applied. You may need to refresh this page to see these updates.', wait: Capybara.default_max_wait_time * 2)
      end
    end
  end
end
