# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Generic File uploading and deletion:', type: :feature do
  let(:new_generic_work_path) { '/concern/generic_works/new' }
  context 'When logged in as a PSU user' do
    let(:current_user)          { create(:user) }
    let(:other_user)            { create(:user) }
    let(:filename)              { 'little_file.txt' }
    let(:batch)                 { ['little_file.txt', 'little_file.txt'] }
    let(:file)                  { work }
    let(:work)                  { find_work_by_title "little_file.txt_title" }

    before do
      sign_in_with_js(current_user)
    end

    context 'the user agreement' do
      before do
        visit new_generic_work_path
      end
      it "does not show Sufia's user agreement" do
        expect(page).not_to have_content("Sufia's Deposit Agreement")
      end
    end

    context 'user needs help' do
      before do
        visit new_generic_work_path
        # TODO: It seems that we removed this screen reader only text from the upload form in Sufia 7.
        #       Added ticket to address it: https://github.com/psu-stewardship/scholarsphere/issues/308
        #
        # expect(page).to have_content "Agree to the deposit agreement and then select files.  Press the Start Upload Button once all files have been selected"
        #
        attach_file('files[]', test_file_path(filename), visible: false)
        check 'agreement'
      end

      specify 'I can view help for rights, visibility, and share with' do
        # I can add additional rights
        expect(User).to receive(:query_ldap_by_name_or_id).and_return([{ id: other_user.user_key, text: "#{other_user.display_name} (#{other_user.user_key})" }])
        click_link('Share')
        expect(page).to have_css('a.select2-choice')
        first('a.select2-choice').click
        find(".select2-input").set(other_user.user_key)
        expect(page).to have_css('div.select2-result-label')
        first('div.select2-result-label').click
        find('#new_user_permission_skel').find(:xpath, 'option[2]').select_option
        click_on('add_new_user_skel')
        within("#share") do
          expect(page).to have_content(other_user.user_key)
        end

        # I am adding can click on more descriptions here so we do not need to add a separate test for it
        click_link("Descriptions")
        expect(page).to have_no_css("#generic_work_contributor")
        click_link("Additional fields")
        expect(page).to have_css("#generic_work_contributor")
        expect(page).to have_css(".collapse.in") # wait for JavaScript to collapse fields
        expect(page).to have_content("Published Date")
        click_link("Additional fields")
        expect(page).to have_no_css("#generic_work_contributor")

        within("#savewidget") do
          expect(page).to have_content("Visibility")
          expect(page).to have_content("Public")
          expect(page).to have_content("Embargo")
          expect(page).to have_content("Private")
          expect(page).to have_content("Penn State")
        end

        within("#metadata") do
          expect(page).to have_link("Licenses")
        end
      end
    end

    context 'cloud providers' do
      before do
        allow(BrowseEverything).to receive(:config) { { "dropbox" => { app_key: "fakekey189274942347", app_secret: "fakesecret489289472347298", max_upload_file_size: 20 * 1024 } } }
        allow(Sufia.config).to receive(:browse_everything) { { "dropbox" => { app_key: "fakekey189274942347", app_secret: "fakesecret489289472347298" } } }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:authorized?) { true }
        allow_any_instance_of(BrowseEverything::Driver::Dropbox).to receive(:token) { "FakeDropboxAccessToken01234567890ABCDEF_AAAAAAA987654321" }
        allow_any_instance_of(GenericWork).to receive(:share_notified?).and_return(false)
        visit(new_curation_concerns_generic_work_path)
        WebMock.enable!
      end

      after do
        WebMock.disable!
      end
      specify 'I can click on cloud providers' do
        expect(ShareNotifyJob).to receive(:perform_later)
        VCR.use_cassette('dropbox', record: :none) do
          click_link "Files"
          expect(page).to have_content "Add cloud files"
          click_on "Add cloud files"
          expect(page).to have_css '#provider-select'
          select 'Dropbox', from: 'provider-select'
          sleep 10
          expect(page).to have_content "Getting Started.pdf"
          click_on("Writer")
          expect(page).to have_content "Writer FAQ.txt"
          expect(page).not_to have_css "a", text: "Writer FAQ.txt"
          expect(page).to have_content "Markdown Test.txt"
          check("writer-markdown-test-txt")
          expect(page).to have_content "1 file selected"
          click_on("Submit")
          within "tr.template-download" do
            expect(page).to have_content "Markdown Test.txt"
          end
          check 'agreement'
          click_on 'Descriptions'
          fill_in 'generic_work_title', with: 'Markdown Test'
          fill_in 'generic_work_keyword', with: 'keyword'
          fill_in 'generic_work_creator', with: 'creator'
          select 'Attribution-NonCommercial-NoDerivatives 4.0 International', from: 'generic_work_rights'
          fill_in 'generic_work_description', with: 'My description'
          select 'Audio', from: 'generic_work_resource_type'
          click_on 'Save'
          expect(page).to have_css('h1', 'Markdown Test')
          click_on "Notifications"
          expect(page).to have_content "The file (Markdown Test.txt) was successfully imported"
        end
      end
    end

    context 'user does not need help' do
      context 'with a single file' do
        before do
          create_work_and_upload_file(filename)
          allow(ShareNotifyDeleteJob).to receive(:perform_later)
        end
        specify 'uploading, deleting and notifications' do
          click_link "My Dashboard"
          expect(page).to have_css "table#activity"
          within("table#activity") do
            expect(page).to have_content filename
          end
          # TODO: Re-enable notifications after a file has been added.
          #       See https://github.com/psu-stewardship/scholarsphere/issues/311
          #
          # within("#notifications") do
          #   expect(page).to have_content "Batch upload complete"
          #   expect(page).to have_content "less than a minute ago"
          #   expect(page).to have_content filename
          #   expect(page).to have_content "has been saved."
          # end
          #
          go_to_dashboard_works
          expect(page).to have_content file.title.first
          db_item_actions_toggle(file).click
          click_link 'Delete Work'
          expect(page).to have_content "Deleted #{file.title.first}"
        end
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
