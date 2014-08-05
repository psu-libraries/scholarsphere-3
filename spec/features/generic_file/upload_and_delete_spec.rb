require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:' do

  context 'When logged in as a PSU user' do
    let!(:current_user) { create :user }
    let(:filename)      { 'little_file.txt' }
    let(:batch)         { ['little_file.txt', 'little_file.txt'] }
    let(:file)          { find_file_by_title "little_file.txt" }

    before do
      sign_in_as current_user
    end

    context 'user needs help' do
      before do
        visit new_generic_file_path
        check 'terms_of_service'
        attach_file 'files[]', test_file_path(filename)
        redirect_url = find("#redirect-loc", visible:false).text
        click_button 'main_upload_start'
        wait_for_page redirect_url
        page.should have_content 'Apply Metadata'
      end

      specify 'I can view help for rights, visibility, and share with' do

        #I am adding can click on more metadata here so we do not need to add a separate test for it
        expect(page).not_to have_css("#generic_file_publisher")
        click_on 'Add More Description Types'
        expect(page).to have_css("#generic_file_publisher")

        # If these tests start to randomly fail please consider re-adding
        # the calls to sleep and save_and_open that I removed because they
        # slowed down the execution of the tests. - Hector 7/7/2014

        # Visibility is a tooltip. Click on it once to show it,
        # click again to hide it.
        find('#generic_file_visibility_help').trigger('click')
        expect(page).to have_css('h3.popover-title', text: 'Visibility')
        find('#generic_file_visibility_help').trigger('click')
        expect(page).to_not have_css('h3.popover-title', text: 'Visibility')

        # Share With is a tooltip. Click on it once to show it,
        # click again to hide it.
        find('#generic_file_share_with_help').trigger('click')
        expect(page).to have_css('h3.popover-title', text: 'Share with')
        find('#generic_file_share_with_help').trigger('click')
        expect(page).to_not have_css('h3.popover-title', text: 'Share with')

        # Rights (i.e. License Descriptions) is a modal form
        # with a close button.
        expect(page).to_not have_css('#rightsModal')
        find('#generic_file_rightsModal_help_modal').click()
        modal = find('#rightsModal')
        expect(modal[:style]).to match(/display: block/)
        expect(page).to have_css('#rightsModal')
        expect(page).to have_content('Creative Commons licenses can take the following combinations')
        click_on('Close')

        # The following tests might work in your local environment
        # but randomly fail in Travis/Jenkins
        #
        # modal_closed = find('#rightsModal', visible: false)
        # expect(modal_closed[:style]).to match(/display: none/)
        #
        # expect(page).to_not have_content('Creative Commons licenses can take the following combinations')
        # page.should_not have_selector(:css, '#rightsModal')
      end

    end
    context 'cloud providers' do
      before do
        allow(BrowseEverything).to receive(:config) { {"drop_box"=>{:app_key=>"fakekey189274942347", :app_secret=>"fakesecret489289472347298"}} }
        allow(Sufia.config).to receive(:browse_everything) { {"drop_box"=>{:app_key=>"fakekey189274942347", :app_secret=>"fakesecret489289472347298"}} }
        allow_any_instance_of(BrowseEverything::Driver::DropBox).to receive(:authorized?) { true }
        allow_any_instance_of(BrowseEverything::Driver::DropBox).to receive(:token) { "FakeDropboxAccessToken01234567890ABCDEF_AAAAAAA987654321" }
        visit new_generic_file_path
        WebMock.enable!
      end

      after do
        WebMock.disable!
      end
      specify 'I can click on cloud providers' do
        VCR.use_cassette('dropbox', record: :none) do
          expect(page).to have_xpath("//a[@href='#browse_everything']")
          click_link "Cloud Providers"
          expect(page).to have_content "Browse cloud files"
          click_on "Browse cloud files"
          expect(page).to have_css '#provider-select'
          select 'Drop Box', from: 'provider-select'
          expect(page).to have_content "Getting Started.pdf"
          click_on("Writer")
          expect(page).to have_content "Writer FAQ.txt"
          click_on("Markdown Test.txt")
          expect(page).to have_content "1 file selected"
          click_on("Submit")
          expect(page).to have_content "Submit 1 selected files"
          check 'terms_of_service'
          click_on("Submit 1 selected files")
          page.should have_content 'Apply Metadata'
          fill_in 'generic_file_tag', with: 'dropbox_tag'
          fill_in 'generic_file_creator', with: 'dropbox_creator'
          select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
          click_on 'upload_submit'
          page.should have_css '#documents'
          page.should have_content "Markdown+Test.txt"
        end
      end
    end

    context 'user does not need help' do

      context 'with a single file' do
        before do
          upload_generic_file filename
        end
        specify 'uploading, deleting and notifications' do
          page.should have_css '#documents'
          page.should have_content filename
          click_link "dashboard_link"
          page.should have_css "table#activity"
          within ("table#activity") do
            page.should have_content filename
          end
          within ("#notifications") do
            page.should have_content "Batch upload complete"
            page.should have_content "less than a minute ago"
            page.should have_content filename
            page.should have_content "has been saved."
          end
          go_to_dashboard_files
          page.should have_content file.title.first
          db_item_actions_toggle(file).click
          click_link 'Delete File'
          page.should_not have_content file.title.first
        end
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
