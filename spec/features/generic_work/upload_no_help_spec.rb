# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:', type: :feature do
  let(:new_generic_work_path) { '/concern/generic_works/new' }
  let(:current_user)          { create(:user) }
  let(:other_user)            { create(:user) }
  let(:filename)              { 'little_file.txt' }
  let(:batch)                 { ['little_file.txt', 'little_file.txt'] }
  let(:file)                  { work }
  let(:work)                  { find_work_by_title "little_file.txt_title" }

  before { sign_in_with_named_js(:upload_no_help, current_user, disable_animations: true) }

  context 'user does not need help' do
    context 'with a single file' do
      before { allow(ShareNotifyDeleteJob).to receive(:perform_later) }

      specify 'uploading, deleting and notifications' do
        visit '/concern/generic_works/new'
        click_on 'Files'
        attach_file('files[]', test_file_path(filename), visible: false)
        click_on 'Start'
        click_on 'Metadata'
        fill_in 'generic_work_title', with: filename + '_title'
        fill_in 'generic_work_keyword', with: filename + '_keyword'
        fill_in 'generic_work_creator', with: filename + '_creator'
        fill_in 'generic_work_description', with: filename + '_description'
        select 'Audio', from: 'generic_work_resource_type'
        select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'generic_work_rights'
        within("#savewidget") do
          choose 'generic_work_visibility_authenticated'
        end
        check 'agreement'
        sleep(3.seconds)
        click_on 'Save'
        expect(page).to have_css('h1', filename + '_title')
        click_link "My Dashboard"
        expect(page).to have_css "table#activity"
        within("table#activity") do
          expect(page).to have_content filename
        end
        within("#notifications") do
          expect(page).to have_content "little_file.txt was successfully added"
        end
        go_to_dashboard_works
        expect(page).to have_content file.title.first
        db_item_actions_toggle(file).click
        click_link 'Delete Work'
        expect(page).to have_content "Deleted #{file.title.first}"
      end
    end
  end
end
