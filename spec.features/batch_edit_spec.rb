require_relative './feature_spec_helper'

describe "Batch management of generic files" do
  let(:current_user) { create(:user) }
  let(:filenames) { %w{world.png small_file.txt} }
  before do
    sign_in_as current_user
    # create some files via the browser
    filenames.each do |filename|
      upload_generic_files filename
    end
  end
  describe "Editing multiple files" do
    context "Filling in each field on the ?? form" do
      before do
        # visit the page and fill in all form fields
        check 'check_all'
        click_on 'batch-edit'
        page.should have_content 'Batch Edit Descriptions'
        expand 'Contributor'
        fill_in_field 'contributor'
        expand 'Publisher'
        fill_in_field 'publisher'
       #fill_in_field 'Date Created'
    #   expand 'Subject'
    #   fill_in_field 'subject'
    #   expand 'Language'
    #   fill_in_field 'language'
    #   expand 'Identifier'
    #   fill_in_field 'identifier'
        expand 'Location'
        fill_in_field 'location'
       #fill_in_field 'Related URL'
        click_link 'Dashboard'
      end
      it "Saves each field to the database" do
        file_1 = GenericFile.first
        file_2 = GenericFile.last
        file_1.contributor.should == ['NEW contributor']
        file_2.contributor.should == ['NEW contributor']
        file_1.contributor.should == ['NEW publisher']
        file_2.contributor.should == ['NEW publisher']
    #   file_1.contributor.should == ['NEW subject']
    #   file_2.contributor.should == ['NEW subject']
    #   file_1.contributor.should == ['NEW language']
    #   file_2.contributor.should == ['NEW language']
    #   file_1.contributor.should == ['NEW identifier']
    #   file_2.contributor.should == ['NEW identifier']
        file_1.contributor.should == ['NEW location']
        file_2.contributor.should == ['NEW location']
       #file_1.contributor.should == ['NEW publisher']
       #file_2.contributor.should == ['NEW publisher']
      end
    end
    context "Viewing the ?? form" do
      before do
        # assign all form fields
      end
      it "Fills in each field from the database"
    end
  end
  describe "Deleting multiple files" do
    context "Selecting all my files to delete" do
      before do
        # visit dashboard, select all files, and delete them
      end
      it "Removes the files from the system"
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
    p label
    within "#collapse_#{label}" do
      fill_in "generic_file[#{label}][]", with: "NEW #{label}"
      click_button "#{label}_save"
      page.should have_content 'Changes Saved'
    end
  end

  def expand(label)
    click_link label
  end
end
