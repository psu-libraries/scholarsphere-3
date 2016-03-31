# frozen_string_literal: true
# This spec unconvered a front end bug when editing
# multiple attributes. Although the attributes seem
# to be saved in the database, the front end behavior
# does not allow us to confirm any updates.
require 'feature_spec_helper'

describe 'Batch management of generic files', type: :feature do
  let(:current_user) { create(:user) }
  let!(:file1)       { create(:public_file, :with_complete_metadata, depositor: current_user.login) }
  let!(:file2)       { create(:public_file, :with_complete_metadata, depositor: current_user.login) }

  before do
    sign_in_with_js(current_user)
    go_to_dashboard_files
  end

  describe 'editing and viewing multiple files' do
    before do
      check 'check_all'
      click_on 'batch-edit'
      assert page.has_content? 'Batch Edit Descriptions'
      fields.each { |f| fill_in_field(f) }
      file1.reload
      file2.reload
    end
    it 'edits each field and displays the changes', js: true do
      expect(file1.contributor).to eq ['NEW contributor']
      expect(file1.description).to eq ['NEW description']
      expect(file1.tag).to eq ['NEW tag']
      expect(file1.publisher).to eq ['NEW publisher']
      expect(file1.date_created).to eq ['NEW date_created']
      expect(file1.subject).to eq ['NEW subject']
      expect(file1.language).to eq ['NEW language']
      expect(file1.identifier).to eq ['NEW identifier']
      expect(file1.based_near).to eq ['NEW based_near']
      expect(file1.related_url).to eq ['NEW related_url']
      expect(file2.contributor).to eq ['NEW contributor']
      expect(file2.description).to eq ['NEW description']
      expect(file2.tag).to eq ['NEW tag']
      expect(file2.publisher).to eq ['NEW publisher']
      expect(file2.date_created).to eq ['NEW date_created']
      expect(file2.subject).to eq ['NEW subject']
      expect(file2.language).to eq ['NEW language']
      expect(file2.identifier).to eq ['NEW identifier']
      expect(file2.based_near).to eq ['NEW based_near']
      expect(file2.related_url).to eq ['NEW related_url']

      # Reload the form and verify
      visit '/dashboard/files'
      check 'check_all'
      click_on 'batch-edit'
      expect(page).to have_content('Batch Edit Descriptions')
      expand("contributor")
      expect(page).to have_css "input#generic_file_contributor[value*='NEW contributor']"
      expand("description")
      expect(page).to have_css "textarea#generic_file_description", 'NEW description'
      expand("tag")
      expect(page).to have_css "input#generic_file_tag[value*='NEW tag']"
      expand("publisher")
      expect(page).to have_css "input#generic_file_publisher[value*='NEW publisher']"
      expand("date_created")
      expect(page).to have_css "input#generic_file_date_created[value*='NEW date_created']"
      expand("subject")
      expect(page).to have_css "input#generic_file_subject[value*='NEW subject']"
      expand("language")
      expect(page).to have_css "input#generic_file_language[value*='NEW language']"
      expand("identifier")
      expect(page).to have_css "input#generic_file_identifier[value*='NEW identifier']"
      expand("based_near")
      expect(page).to have_css "input#generic_file_based_near[value*='NEW based_near']"
      expand("related_url")
      expect(page).to have_css "input#generic_file_related_url[value*='NEW related_url']"
    end
  end

  describe 'Deleting multiple files', js: true do
    context 'Selecting all my files to delete' do
      before do
        visit '/dashboard/files'
        check 'check_all'
        click_button 'Delete Selected'
      end
      it 'Removes the files from the system' do
        expect(GenericFile.count).to be_zero
      end
    end
  end

  def fields
    [
      "contributor", "description", "tag", "publisher", "date_created", "subject",
      "based_near", "language", "identifier", "related_url"
    ]
  end

  def fill_in_field(id)
    expand(id)
    within "#form_#{id}" do
      fill_in "generic_file_#{id}", with: "NEW #{id}"
      click_button "#{id}_save"
    end
    within "#form_#{id}" do
      sleep 0.1 until page.text.include?('Changes Saved')
      expect(page).to have_content 'Changes Saved', wait: Capybara.default_max_wait_time * 4
    end
  end

  def expand(field)
    link = find("#expand_link_#{field}")
    while link["class"].include?("collapsed")
      sleep 0.1
      link.click if link["class"].include?("collapsed")
    end
  end
end
