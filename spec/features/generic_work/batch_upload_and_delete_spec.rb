# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Generic File batch uploading', type: :feature do
  context 'when logged in as a PSU user' do
    let(:current_user)          { create(:user) }
    let(:other_user)            { create(:user) }
    let(:filename)              { 'little_file.txt' }
    let(:batch)                 { ['little_file.txt', 'little_file.txt'] }
    let(:file)                  { work }
    let(:work)                  { find_work_by_title 'little_file.txt_title' }

    before { sign_in_with_named_js(:batch_upload_and_delete, current_user) }

    describe 'uploading a new work' do
      it 'enforces a workflow' do
        Sufia::AdminSetCreateService.create_default!
        visit '/'
        click_on 'Works'
        click_on 'Batch Create'

        within('form#new_batch_upload_item') { expect(page).to have_selector('input#batch_upload_item_payload_concern', visible: false) }

        click_on 'Files'
        attach_file('files[]', test_file_path(filename), visible: false)
        click_on 'Start'

        click_on 'Metadata'
        fill_in 'batch_upload_item_keyword', with: 'keyword'
        select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'batch_upload_item_rights'
        fill_in 'batch_upload_item_description', with: 'My description'

        within('div#savewidget') { expect(page).to have_link('Required metadata complete') }
        check 'agreement'
        click_on 'Save'
        expect(page).to have_content('Your files are being processed by ScholarSphere in the background. The metadata and access controls you specified are being applied. You may need to refresh this page to see these updates.')
      end
    end
  end
end
