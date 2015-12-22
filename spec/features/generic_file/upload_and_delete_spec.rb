require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:', type: :feature do
  context 'When logged in as a PSU user' do
    let!(:current_user) { create :user }
    let(:other_user) { create :user }
    let(:filename) { 'little_file.txt' }
    let(:batch) { ['little_file.txt', 'little_file.txt'] }
    let(:file) { find_file_by_title "little_file.txt" }

    before do
      sign_in_as current_user
    end

    context 'the user agreement' do
      before do
        Sufia::Engine.routes.url_helpers.new_generic_file_path
      end
      it "does not show Sufia's user agreement" do
        expect(page).to_not have_content("Sufia's Deposit Agreement")
      end
    end

    context 'user needs help' do
      before do
        visit Sufia::Engine.routes.url_helpers.new_generic_file_path
        expect(page).to have_content "Agree to the deposit agreement and then select files.  Press the Start Upload Button once all files have been selected"
        check 'terms_of_service'
        attach_file 'files[]', test_file_path(filename)
        redirect_url = find("#redirect-loc", visible: false).text(:all)
        click_button 'main_upload_start'
        wait_for_page redirect_url
        expect(page).to have_content 'Apply Metadata'
      end

      specify 'I can view help for rights, visibility, and share with' do
        # I can add additional rights
        expect(User).to receive(:query_ldap_by_name_or_id).and_return([{ id: other_user.user_key, text: "#{other_user.display_name} (#{other_user.user_key})" }])
        find('.select2-container').click
        sleep(1)
        find('#select2-drop .select2-input').set other_user.user_key
        find('#select2-drop .select2-result-selectable').click
        find('#new_user_permission_skel').find(:xpath, 'option[2]').select_option
        click_on "add_new_user_skel"
        expect(page).to have_css("label.control-label", text: other_user.user_key)

        # I am adding can click on more metadata here so we do not need to add a separate test for it
        expect(page).not_to have_css("#generic_file_publisher")
        click_on 'Show Additional Fields'
        expect(page).to have_css("#generic_file_publisher")
        click_on 'Hide Additional Fields'
        expect(page).to_not have_css("#generic_file_publisher")

        # If these tests start to randomly fail please consider re-adding
        # the calls to sleep and save_and_open that I removed because they
        # slowed down the execution of the tests. - Hector 7/7/2014

        # Visibility is a tooltip. Click on it once to show it,
        # click again to hide it.
        within('#visibility_tooltip') do
          find('.help-icon').trigger('click')
          expect(page).to have_css('h3.popover-title', text: 'Visibility')
          find('.help-icon').trigger('click')
          expect(page).to_not have_css('h3.popover-title', text: 'Visibility')
        end

        # Share With is a tooltip. Click on it once to show it,
        # click again to hide it.
        within('#share_with_tooltip') do
          find('.help-icon').trigger('click')
          expect(page).to have_css('h3.popover-title', text: 'Share With')
          find('.help-icon').trigger('click')
          expect(page).to_not have_css('h3.popover-title', text: 'Share With')
        end

        # Rights (i.e. License Descriptions) is a modal form
        # with a close button.
        expect(page).to_not have_css('#rightsModal')
        within('#generic_file_rights_help_modal') do
          find('.help-icon').click
        end
        expect(page).to have_css('#rightsModal')
        expect(page).to have_css('h2#rightsModallLabel', text: 'ScholarSphere License Descriptions')
        modal = find('#rightsModal')
        expect(modal[:style]).to match(/display: block/)
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
        allow(BrowseEverything).to receive(:config) { { "dropbox" => { app_key: "fakekey189274942347", app_secret: "fakesecret489289472347298", max_upload_file_size: 20 * 1024 } } }
        allow(Sufia.config).to receive(:browse_everything) { { "dropbox" => { app_key: "fakekey189274942347", app_secret: "fakesecret489289472347298" } } }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:authorized?) { true }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:token) { "FakeDropboxAccessToken01234567890ABCDEF_AAAAAAA987654321" }
        allow_any_instance_of(GenericFile).to receive(:share_notified?).and_return(false)
        visit Sufia::Engine.routes.url_helpers.new_generic_file_path
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
          select 'Dropbox', from: 'provider-select'
          sleep 10
          expect(page).to have_content "Getting Started.pdf"
          click_on("Writer")
          expect(page).to have_content "Writer FAQ.txt"
          expect(page).not_to have_css "a", text: "Writer FAQ.txt"
          expect(page).to have_content "Markdown Test.txt"
          find("a", text: "Markdown Test.txt").trigger("click")
          expect(page).to have_content "1 file selected"
          click_on("Submit")
          expect(page).to have_content "Submit 1 selected files"
          check 'terms_of_service'
          click_on("Submit 1 selected files")
          uri = URI.parse(current_url)
          batch = uri.path.split("/")[2]
          expect(page).to have_content 'Apply Metadata'
          expect(page).not_to have_css("div.alert-danger")
          fill_in 'generic_file_tag', with: 'dropbox_tag'
          fill_in 'generic_file_creator', with: 'dropbox_creator'
          select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
          click_on 'upload_submit'
          expect(page).to have_css '#documents'
          expect(page).to have_content "Markdown Test.txt"
          click_on "notify_link"
          expect(page).to have_content "The file (Markdown Test.txt) was successfully imported"
          expect(page).to have_content "Markdown Test.txt has been saved"
          expect(page).to have_css "span#ss-#{batch}"
        end
      end
    end

    context 'user does not need help' do
      context 'with a single file' do
        before do
          upload_generic_file filename
        end
        specify 'uploading, deleting and notifications' do
          expect(page).to have_css '#documents'
          expect(page).to have_content filename
          click_link "dashboard_link"
          expect(page).to have_css "table#activity"
          within("table#activity") do
            expect(page).to have_content filename
          end
          within("#notifications") do
            expect(page).to have_content "Batch upload complete"
            expect(page).to have_content "less than a minute ago"
            expect(page).to have_content filename
            expect(page).to have_content "has been saved."
          end
          go_to_dashboard_files
          expect(page).to have_content file.title.first
          db_item_actions_toggle(file).click
          click_link 'Delete File'
          expect(page).not_to have_content file.title.first
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
      visit Sufia::Engine.routes.url_helpers.new_generic_file_path
      expect(page).to have_content 'Unauthorized'
      expect(page).not_to have_content 'Upload'
    end
  end
end
