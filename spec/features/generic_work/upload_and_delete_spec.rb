# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:', type: :feature do
  let(:new_generic_work_path) { '/concern/generic_works/new' }

  context 'when logged in as a PSU user' do
    let(:current_user)          { create(:user) }
    let(:other_user)            { create(:user) }
    let(:filename)              { 'little_file.txt' }
    let(:batch)                 { ['little_file.txt', 'little_file.txt'] }
    let(:file)                  { work }
    let(:work)                  { find_work_by_title 'little_file.txt_title' }

    before do
      sign_in_with_named_js(:upload_and_delete, current_user, disable_animations: true)
      allow(CharacterizeJob).to receive(:perform_later)
      allow(ShareNotifyDeleteJob).to receive(:perform_later)
      Sufia::AdminSetCreateService.create_default!
      visit(new_curation_concerns_generic_work_path)
    end

    context 'cloud providers' do
      before do
        allow(BrowseEverything).to receive(:config) { { 'dropbox' => { app_key: 'fakekey189274942347', app_secret: 'fakesecret489289472347298', max_upload_file_size: 20 * 1024 } } }
        allow(Sufia.config).to receive(:browse_everything) { { 'dropbox' => { app_key: 'fakekey189274942347', app_secret: 'fakesecret489289472347298' } } }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:authorized?) { true }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:token) { 'FakeDropboxAccessToken01234567890ABCDEF_AAAAAAA987654321' }
        allow_any_instance_of(GenericWork).to receive(:share_notified?).and_return(false)
        WebMock.enable!
      end

      after do
        WebMock.disable!
      end
      specify 'I can click on cloud providers' do
        expect(ShareNotifyJob).to receive(:perform_later)
        VCR.use_cassette('dropbox', record: :none) do
          click_link 'Files'
          expect(page).to have_content 'Add cloud files'
          click_on 'Add cloud files'
          expect(page).to have_css '#provider-select'
          select 'Dropbox', from: 'provider-select'
          sleep(1.second)
          expect(page).to have_content 'Getting Started.pdf'
          click_on('Writer')
          sleep(1.second)
          expect(page).to have_content 'Writer FAQ.txt'
          expect(page).not_to have_css 'a', text: 'Writer FAQ.txt'
          expect(page).to have_content 'Markdown Test.txt'
          check('writer-markdown-test-txt')
          expect(page).to have_content '1 file selected'
          click_on('Submit')
          within 'tr.template-download' do
            expect(page).to have_content 'Markdown Test.txt'
          end
          within('#savewidget') do
            choose 'generic_work_visibility_authenticated'
          end
          sleep(1.second)
          check 'agreement'
          click_on 'Metadata'
          fill_in 'generic_work_title', with: 'Markdown Test'
          fill_in 'generic_work_keyword', with: 'keyword'
          fill_in 'generic_work[creators][0][given_name]', with: 'creator'
          select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'generic_work_rights'
          fill_in 'generic_work_description', with: 'My description'
          select 'Audio', from: 'generic_work_resource_type'
          sleep(2.seconds)
          click_on 'Save'
          expect(page).to have_content 'Your files are being processed'
          within('#activity_log') do
            expect(page).to have_content("User #{current_user.display_name} has deposited Markdown Test")
          end
          expect(page).to have_css('h1', 'Markdown Test')
          click_on 'Notifications'
          expect(page).to have_content 'The file (Markdown Test.txt) was successfully imported'
        end
      end
    end

    context 'with a single local file' do
      let(:new_creator) { Agent.where(psu_id: 'jhc29').first }

      it 'uploads the file, sends notification, creates new agent records, and deletes the file' do
        # Verify agent does not exist
        expect(Agent.where(psu_id: 'jhc29').first).to be_nil

        within('div#savewidget') do
          expect(page).to have_link 'deposit agreement'
          expect(page).to have_content 'I have read and agree to the deposit agreement'
          expect(page).to have_link('Enter required metadata')
          expect(page).to have_link('Add files')
        end

        # Sufia's default user agreement does not show
        expect(page).not_to have_content("Sufia's Deposit Agreement")

        # Add files
        click_on 'Files'
        attach_file('files[]', test_file_path(filename), visible: false)
        click_on 'Start'

        # Check visibility
        within('#savewidget') do
          expect(page).to have_content('Visibility')
          expect(page).to have_content('Public')
          expect(page).to have_content('Embargo')
          expect(page).not_to have_content('Private')
          expect(page).to have_content('Penn State')
          expect(page).to have_checked_field('Public')
          expect(page).to have_content('marking this as Public')
          sleep(1.second)
          choose 'generic_work_visibility_authenticated'
          expect(page).not_to have_content('marking this as Public')
        end

        # Enter required metadata
        click_link('Metadata')
        fill_in 'generic_work_title', with: filename + '_title'
        fill_in 'generic_work_keyword', with: filename + '_keyword'
        fill_in 'generic_work[creators][0][given_name]', with: 'Joe'
        fill_in 'generic_work[creators][0][sur_name]', with: 'Creator'
        fill_in 'generic_work[creators][0][display_name]', with: 'Dr. Joe H. Creator'
        fill_in 'generic_work[creators][0][psu_id]', with: 'jhc29'
        fill_in 'generic_work[creators][0][email]', with: 'docjoe@university.edu'
        fill_in 'generic_work_description', with: filename + '_description'
        select 'Audio', from: 'generic_work_resource_type'
        select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'generic_work_rights'

        within('#metadata')      { expect(page).to have_link('Licenses') }
        within('#metadata')      { expect(page).not_to have_css('#work-media') }
        within('div#savewidget') { expect(page).to have_link('Required metadata complete') }

        # Check for additional fields
        expect(page).to have_no_css('#generic_work_contributor')
        click_link('Additional Fields')
        expect(page).to have_css('#generic_work_contributor')
        expect(page).to have_css('.collapse.in') # wait for JavaScript to collapse fields
        expect(page).to have_content('Published Date')
        click_link('Additional Fields')
        expect(page).to have_no_css('#generic_work_contributor')

        # Check for optional metadata
        within('#form-progress') { click_link('Collections') }
        within('#form-progress') { click_link('Collaborators') }

        # Test sharing tab
        expect(User).to receive(:query_ldap_by_name_or_id).and_return([{ id: other_user.user_key, text: "#{other_user.display_name} (#{other_user.user_key})" }])
        within('ul.nav-tabs') { click_link('Collaborators') }
        expect(page).to have_css('a.select2-choice')
        first('a.select2-choice').click
        find('.select2-input').set(other_user.user_key)
        expect(page).to have_css('div.select2-result-label')
        first('div.select2-result-label').click
        find('#new_user_permission_skel').find(:xpath, 'option[2]').select_option
        click_on('add_new_user_skel')
        within('#share') { expect(page).to have_content(other_user.user_key) }

        # Test Collections tab for select2 container
        within('ul.nav-tabs') { click_link('Collections') }
        expect(page).to have_css('.select2-container-multi')

        within('#savewidget') do
          choose 'generic_work_visibility_authenticated'
        end
        sleep(2.seconds)
        check 'agreement'
        sleep(2.seconds)
        click_on 'Save'
        expect(page).to have_css('h1', filename + '_title')
        click_link 'My Dashboard'
        expect(page).to have_css 'table#activity'
        within('table#activity') do
          expect(page).to have_content filename
        end

        # Verify notifications were sent
        within('#notifications') do
          expect(page).to have_content 'little_file.txt was successfully added'
        end

        # Check for the agent record
        expect(new_creator.given_name).to eq('Joe')
        expect(new_creator.sur_name).to eq('Creator')
        expect(new_creator.email).to eq('docjoe@university.edu')
        expect(new_creator.psu_id).to eq('jhc29')

        go_to_dashboard_works
        expect(page).to have_content file.title.first
        db_item_actions_toggle(file).click
        click_link 'Delete Work'
        expect(page).to have_content "Deleted #{file.title.first}"
      end
    end
  end

  context 'When logged in as a non-PSU user' do
    let(:current_user) { create(:non_psu_user) }

    before { sign_in_with_js(current_user) }

    specify 'I cannot access the upload page' do
      visit new_generic_work_path
      expect(page).to have_content 'Unauthorized'
      expect(page).not_to have_content 'Upload'
    end
  end
end
