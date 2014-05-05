require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Collection viewing and searching:' do

  let(:current_user) { create :user }
  let(:filenames) { %w{world.png small_file.txt} }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }
  let(:collection) { Collection.first }

  before do
    sign_in_as current_user
    filenames.each do |filename|
      upload_generic_file filename
    end
    check 'check_all'
    click_button 'Add to Collection'
    db_create_populated_collection_button.click
    create_collection title, creator, description
    visit '/dashboard'
    db_item_title(collection).click
  end

  let(:file_1) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"world.png").first }
  let(:file_2) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"small_file.txt").first }

  describe 'When viewing a collection' do
    specify "I should see the collection's metadata" do
      page.should have_content title
      page.should have_content description
      page.should have_content creator
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
    end
  end

  describe 'When searching within a collection' do
    before do
      fill_in 'collection_search', with: file_1.title.first
      click_button 'collection_submit'
    end
    specify 'I should see the correct results' do
      page.should have_content title
      page.should have_content description

      # Should have search results / contents listing
      page.should have_content file_1.title.first
      page.should_not have_content file_2.title.first

      # Should not have Collection Descriptive metadata table
      page.should_not have_content creator
    end
  end
end
