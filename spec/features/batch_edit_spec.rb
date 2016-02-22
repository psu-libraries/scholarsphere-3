# frozen_string_literal: true
# This spec unconvered a front end bug when editing
# multiple attributes. Although the attributes seem
# to be saved in the database, the front end behavior
# does not allow us to confirm any updates.
require 'feature_spec_helper'

describe 'Batch management of generic files', type: :feature do
  let(:current_user) { FactoryGirl.find_or_create(:user) }
  let!(:file_1)       { create_file current_user, title: 'world.png' }
  let!(:file_2)       { create_file current_user, title: 'little_file.txt' }

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
      file_1.reload
      file_2.reload
    end
    it 'edits each field and displays the changes', js: true do
      expect(file_1.contributor).to eq ['NEW contributor']
      expect(file_1.description).to eq ['NEW description']
      expect(file_1.tag).to eq ['NEW tag']
      expect(file_1.publisher).to eq ['NEW publisher']
      expect(file_1.date_created).to eq ['NEW date_created']
      expect(file_1.subject).to eq ['NEW subject']
      expect(file_1.language).to eq ['NEW language']
      expect(file_1.identifier).to eq ['NEW identifier']
      expect(file_1.based_near).to eq ['NEW based_near']
      expect(file_1.related_url).to eq ['NEW related_url']
      expect(file_2.contributor).to eq ['NEW contributor']
      expect(file_2.description).to eq ['NEW description']
      expect(file_2.tag).to eq ['NEW tag']
      expect(file_2.publisher).to eq ['NEW publisher']
      expect(file_2.date_created).to eq ['NEW date_created']
      expect(file_2.subject).to eq ['NEW subject']
      expect(file_2.language).to eq ['NEW language']
      expect(file_2.identifier).to eq ['NEW identifier']
      expect(file_2.based_near).to eq ['NEW based_near']
      expect(file_2.related_url).to eq ['NEW related_url']

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
