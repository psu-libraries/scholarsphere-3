# This spec unconvered a front end bug when editing
# multiple attributes. Although the attributes seem
# to be saved in the database, the front end behavior
# does not allow us to confirm any updates.
require_relative './feature_spec_helper'

describe 'Batch management of generic files', :type => :feature do
  skip "These test are causing issues on Travis"

  let!(:current_user) { create :user }
  let!(:file_1) { create_file current_user, {title:'world.png'} }
  let!(:file_2) { create_file current_user, {title:'little_file.txt'} }
##  let(:filenames) { %w{world.png little_file.txt} }

  before do
    sign_in_as current_user
    go_to_dashboard_files
  end

  describe 'Editing multiple files' do

    context 'Filling in each field on the batch edit form' do
      before do
        # visit the page and fill in all form fields
        check 'check_all'
        click_on 'batch-edit'
        assert page.has_content? 'Batch Edit Descriptions'
        expand_all_fields
        fill_in_fields ['contributor', 'description', 'tag', 'publisher',
                        'date_created', 'subject', 'language', 'identifier',
                        'based_near', 'related_url']
        file_1.reload
        file_2.reload
      end
      it 'Saves each field to the database' do
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
        expand_all_fields
      end
      it 'Fills in each field from the database' do
        expect(page).to have_css "input#generic_file_contributor[value*='NEW contributor']"
        expect(page).to have_css "textarea#generic_file_description",'NEW description'
        expect(page).to have_css "input#generic_file_tag[value*='NEW tag']"
        expect(page).to have_css "input#generic_file_publisher[value*='NEW publisher']"
        expect(page).to have_css "input#generic_file_date_created[value*='NEW date_created']"
        expect(page).to have_css "input#generic_file_subject[value*='NEW subject']"
        expect(page).to have_css "input#generic_file_language[value*='NEW language']"
        expect(page).to have_css "input#generic_file_identifier[value*='NEW identifier']"
        expect(page).to have_css "input#generic_file_based_near[value*='NEW based_near']"
        expect(page).to have_css "input#generic_file_related_url[value*='NEW related_url']"
      end
    end
  end

  describe 'Deleting multiple files' do
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

  def fill_in_field label
    within "#form_#{label}" do
      fill_in "generic_file_#{label}", with: "NEW #{label}"
      click_button "#{label}_save"
      expect(page).to have_content 'Changes Saved'
    end
  end

  def fill_in_fields labels
    labels.each do |label|
      within "#form_#{label}" do
        fill_in "generic_file_#{label}", with: "NEW #{label}"
        click_button "#{label}_save"
      end
    end
    labels.each do |label|
      within "#form_#{label}" do
        expect(page).to have_content 'Changes Saved'
      end
    end
  end

  def expand label
    click_link label
  end

  def expand_all_fields
    all(".accordion-toggle:not(.btn).collapsed").each do |link|
      expand link.text
    end
    #all(".accordion-toggle:not(.btn)").each do |link|
    #  id =  link["href"].gsub("#","")
    #  puts "id = id"
    #  expect(page).to have_css("div##{id}", wait: Capybara.default_max_wait_time*4)
    #end

  end
end
