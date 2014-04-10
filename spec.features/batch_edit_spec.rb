require_relative './feature_spec_helper'

describe "Batch management of generic files" do
  let(:current_user) { create(:user) }
  let(:filenames) { %w{world.png small_file.txt} }
  before do
    GenericFile.destroy_all
    sign_in_as current_user
    # create some files
    filenames.each do |filename|
      upload_generic_files filename
    end
  end
  describe "Editing multiple files" do
    let(:file_1) { GenericFile.first }
    let(:file_2) { GenericFile.last }
    context "Filling in each field on the batch edit form" do
      before do
        # visit the page and fill in all form fields
        check 'check_all'
        click_on 'batch-edit'
        page.should have_content 'Batch Edit Descriptions'
        expand_all_fields
        fill_in_field 'contributor'
    #   fill_in_field 'description'
    #   fill_in_field 'tag'
    #   fill_in_field 'publisher'
    #   fill_in_field 'date_created'
    #   fill_in_field 'subject'
    #   fill_in_field 'language'
    #   fill_in_field 'identifier'
    #   fill_in_field 'based_near'
    #   fill_in_field 'related_url'
      end
      it "Saves each field to the database" do
        file_1.contributor.should == ['NEW contributor']
        file_2.contributor.should == ['NEW contributor']
    #   file_1.description.should == ['NEW description']
    #   file_2.description.should == ['NEW description']
    #   file_1.tag.should == ['NEW tag']
    #   file_2.tag.should == ['NEW tag']
    #   file_1.publisher.should == ['NEW publisher']
    #   file_2.publisher.should == ['NEW publisher']
    #   file_1.date_created.should == ['NEW date_created']
    #   file_2.date_created.should == ['NEW date_created']
    #   file_1.subject.should == ['NEW subject']
    #   file_2.subject.should == ['NEW subject']
    #   file_1.language.should == ['NEW language']
    #   file_2.language.should == ['NEW language']
    #   file_1.identifier.should == ['NEW identifier']
    #   file_2.identifier.should == ['NEW identifier']
    #   file_1.based_near.should == ['NEW based_near']
    #   file_2.based_near.should == ['NEW based_near']
    #   file_1.related_url.should == ['NEW related_url']
    #   file_2.related_url.should == ['NEW related_url']
      end
    end
    context "Viewing the batch edit form" do
      before do
        # assign all form fields
        file_1.contributor  = ['NEW contributor']
        file_2.contributor  = ['NEW contributor']
        file_1.description  = ['NEW description']
        file_2.description  = ['NEW description']
        file_1.tag          = ['NEW tag']
        file_2.tag          = ['NEW tag']
        file_1.publisher    = ['NEW publisher']
        file_2.publisher    = ['NEW publisher']
        file_1.date_created = ['NEW date_created']
        file_2.date_created = ['NEW date_created']
        file_1.subject      = ['NEW subject']
        file_2.subject      = ['NEW subject']
        file_1.language     = ['NEW language']
        file_2.language     = ['NEW language']
        file_1.identifier   = ['NEW identifier']
        file_2.identifier   = ['NEW identifier']
        file_1.based_near   = ['NEW based_near']
        file_2.based_near   = ['NEW based_near']
        file_1.related_url  = ['NEW related_url']
        file_2.related_url  = ['NEW related_url']
        file_1.save!
        file_2.save!
        visit '/dashboard'
        check 'check_all'
        click_on 'batch-edit'
        page.should have_content 'Batch Edit Descriptions'
        expand_all_fields
      end
      it "Fills in each field from the database" do
        find('#generic_file_contributor').value.should == 'NEW contributor'
        find('#generic_file_description').value.should == 'NEW description'
        find('#generic_file_tag').value.should == 'NEW tag'
        find('#generic_file_publisher').value.should == 'NEW publisher'
        find('#generic_file_date_created').value.should == 'NEW date_created'
        find('#generic_file_subject').value.should == 'NEW subject'
        find('#generic_file_language').value.should == 'NEW language'
        find('#generic_file_identifier').value.should == 'NEW identifier'
        find('#generic_file_based_near').value.should == 'NEW based_near'
        find('#generic_file_related_url').value.should == 'NEW related_url'
      end
    end
  end
  describe "Deleting multiple files" do
    context "Selecting all my files to delete" do
      before do
        # visit dashboard, select all files, and delete them
        visit '/dashboard'
        check 'check_all'
        click_button 'Delete Selected'
      end
      it "Removes the files from the system" do
        GenericFile.count.should be_zero
      end
    end
  end

  def upload_generic_files(filename)
    visit new_generic_file_path
    check "terms_of_service"
    attach_file("files[]", test_file_path(filename))
    click_button 'main_upload_start'
    page.should have_content 'Apply Metadata'
    fill_in 'generic_file_tag', with: filename + '_tag'
    fill_in 'generic_file_creator', with: filename + '_creator'
    select 'Attribution-NonCommercial-NoDerivs 3.0 United States', from: 'generic_file_rights'
    click_on 'upload_submit'
    page.should have_content 'My Dashboard'
    page.should have_content filename
  end

  def fill_in_field(label)
    within "#form_#{label}" do
      fill_in "generic_file[#{label}][]", with: "NEW #{label}"
      click_button "#{label}_save"
      page.should have_content 'Changes Saved'
    end
  end

  def expand(label)
    click_link label
  end

  def expand_all_fields
    all(".accordion-toggle:not(.btn)").each do |link| 
      label = link.text
      click_link label 
    end
  end
end
