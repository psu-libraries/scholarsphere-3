# frozen_string_literal: true
# This spec unconvered a front end bug when editing
# multiple attributes. Although the attributes seem
# to be saved in the database, the front end behavior
# does not allow us to confirm any updates.
require_relative './feature_spec_helper'

describe 'Batch management of generic files', type: :feature do
  let!(:current_user) { create :user }
  let!(:file_1) { create_file current_user, title: 'world.png' }
  let!(:file_2) { create_file current_user, title: 'little_file.txt' }
  ##  let(:filenames) { %w{world.png little_file.txt} }

  before do
    sign_in_as current_user
    go_to_dashboard_files
  end

  describe 'Editing multiple files' do
    context 'Filling in each field on the batch edit form' do
      # Test fails on click_on 'batch_edit' but hands indefinitely with
      # Completed 204 No Content
      # in the log. Disabled with xit to prevent before block from being executed.
      before do
        # visit the page and fill in all form fields
        check 'check_all'
        click_on 'batch-edit'
        assert page.has_content? 'Batch Edit Descriptions'
        fill_in_fields ["Contributor", "Abstract or Summary", "Keyword", "Publisher", "Date Created", "Subject",
                        "Location", "Language", "Identifier", "Related URL"]
        file_1.reload
        file_2.reload
      end
      xit 'Saves each field to the database', js: true do
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
      end
    end

    context 'Viewing the batch edit form' do
      before do
        # assign all form fields
        file_1.contributor  = ['NEW contributor']
        file_1.description  = ['NEW description']
        file_1.tag          = ['NEW tag']
        file_1.publisher    = ['NEW publisher']
        file_1.date_created = ['NEW date_created']
        file_1.subject      = ['NEW subject']
        file_1.language     = ['NEW language']
        file_1.identifier   = ['NEW identifier']
        file_1.based_near   = ['NEW based_near']
        file_1.related_url  = ['NEW related_url']
        file_1.save!
        file_2.contributor  = ['NEW contributor']
        file_2.description  = ['NEW description']
        file_2.tag          = ['NEW tag']
        file_2.publisher    = ['NEW publisher']
        file_2.date_created = ['NEW date_created']
        file_2.subject      = ['NEW subject']
        file_2.language     = ['NEW language']
        file_2.identifier   = ['NEW identifier']
        file_2.based_near   = ['NEW based_near']
        file_2.related_url  = ['NEW related_url']
        file_2.save!
        visit '/dashboard/files'
        check 'check_all'
        click_on 'batch-edit'
        assert page.has_content? 'Batch Edit Descriptions'
      end
      it 'Fills in each field from the database', js: true do
        expand("Contributor")
        expect(page).to have_css "input#generic_file_contributor[value*='NEW contributor']"
        expand("Abstract or Summary")
        expect(page).to have_css "textarea#generic_file_description", 'NEW description'
        expand("Keyword")
        expect(page).to have_css "input#generic_file_tag[value*='NEW tag']"
        expand("Publisher")
        expect(page).to have_css "input#generic_file_publisher[value*='NEW publisher']"
        expand("Date Created")
        expect(page).to have_css "input#generic_file_date_created[value*='NEW date_created']"
        expand("Subject")
        expect(page).to have_css "input#generic_file_subject[value*='NEW subject']"
        expand("Language")
        expect(page).to have_css "input#generic_file_language[value*='NEW language']"
        expand("Identifier")
        expect(page).to have_css "input#generic_file_identifier[value*='NEW identifier']"
        expand("Location")
        expect(page).to have_css "input#generic_file_based_near[value*='NEW based_near']"
        expand("Related URL")
        expect(page).to have_css "input#generic_file_related_url[value*='NEW related_url']"
      end
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

  def fill_in_fields(labels)
    ids = []
    labels.each do |label|
      id = expand(label)
      within "#form_#{id}" do
        expect(page).to have_css("#generic_file_#{id}")
        fill_in "generic_file_#{id}", with: "NEW #{id}"
        click_button "#{id}_save"
      end
      ids << id
    end
    ids.each do |id|
      within "#form_#{id}" do
        sleep 0.1 until page.text.include?('Changes Saved')
        expect(page).to have_content 'Changes Saved', wait: Capybara.default_max_wait_time * 4
      end
    end
  end

  def expand(label)
    # for what ever reason occasionally the expand will fail the first time through, so we wait a bit and try again
    link = find(:link, label, {})
    link.click
    while link["class"].include? "collapsed"
      sleep 0.1
      link.click if link["class"].include? "collapsed"
    end
    expect(page).to have_no_css("##{link['id']}.collapsed")

    div_id = link["href"].delete("#")
    expect(page).to have_css("div##{div_id}")
    div_id.gsub("collapse_", "")
  end
end
