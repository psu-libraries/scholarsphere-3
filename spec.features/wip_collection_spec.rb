# This file is a Work in Progress


require_relative './feature_spec_helper'

include Selectors::Dashboard
include Selectors::EditCollections

describe 'Collections:' do

  let(:current_user) { create :user }
  let(:filenames) { %w{world.png small_file.txt scholarsphere_test4.pdf} }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }

  before do
    GenericFile.destroy_all
    Collection.destroy_all
    sign_in_as current_user
    filenames.each do |filename|
      upload_generic_file filename
    end
  end

  let(:files) { GenericFile.all }
  let(:file_1) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"world.png").first }
  let(:file_2) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"small_file.txt").first }
  let(:file_3) { GenericFile.find(Solrizer.solr_name("desc_metadata__title")=>"scholarsphere_test4.pdf").first }
  let(:collection) { Collection.first }

  describe 'When creating a collection:' do

    specify 'I should be able to create it without any files' do
      db_create_empty_collection_button.click
      create_collection title, creator, description
    end

    specify 'I should be able to create it with files' do
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection title, creator, description
      files.each do |file|
        page.should have_content file.title.first
      end
    end
  end

  describe 'When deleting a collection:' do
    before do
      db_create_empty_collection_button.click
      create_collection title, creator, description
      visit '/dashboard'
      db_item_actions_toggle(collection).click
      click_link 'Delete Collection'
    end

    specify 'I should no longer see it on my dashboard' do
      page.should have_content 'Collection was successfully deleted'
      page.should have_content 'Dashboard'
      page.should_not have_content title
    end
  end

  describe 'When viewing a collection:' do
    before do
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection title, creator, description
      visit '/dashboard'
      db_item_title(collection).click
    end

    it 'I should see its metadata' do
      page.should have_content title
      page.should have_content description
      page.should have_content creator
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
    end
  end

  describe 'When searching within a collection' do
    before do
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection title, creator, description
      visit '/dashboard'
      db_item_title(collection).click
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

  describe 'Updating a collection:' do
    before do
      db_file_checkbox(file_1).click
      db_file_checkbox(file_2).click
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection title, creator, description
      visit '/dashboard'
    end

    describe 'When adding a file to a collection' do
      before do
        db_file_checkbox(file_3).click
        click_button 'Add to Collection'
        db_collection_radio_button(collection).click
        click_button 'Update Collection'
      end

      specify 'I should be able to add files to it' do
        page.should have_content 'Collection was successfully updated.'
        page.should have_content file_3.title.first
      end
    end

    describe 'When editing a collections metadata' do

      let(:updated_title) { 'Updated Title' }
      let(:updated_description) { 'Updtaed description text.' }
      let(:updated_creators) { ['Dorje Trollo', 'Vajrayogini'] }

      before do
        db_item_actions_toggle(collection).click
        click_link 'Edit Collection'
        page.should have_field 'collection_title', with: title
        page.should have_field 'collection_description',
            with: description
        fill_in 'Title', with: updated_title
        fill_in 'Description', with: updated_description
        fill_in 'Creator', with: updated_creators.first
        ec_update_submit.click
      end

      specify 'I should see the new metadata values' do
        page.should_not have_content title
        page.should_not have_content description
        page.should have_content updated_title
        page.should have_content updated_description
        page.should have_content updated_creators.first
      end
    end

    describe 'When removing a file from a collection' do
      before do
        db_item_actions_toggle(collection).click
        click_link 'Edit Collection'
        page.should have_content file_1.title.first
        page.should have_content file_2.title.first
        db_item_actions_toggle(file_1).click
        click_button 'Remove from Collection'
      end

      specify 'I should no longer see the file listed as a member' do
        page.should have_content title
        page.should have_content description
        page.should_not have_content file_1.title.first
        page.should have_content file_2.title.first
      end
    end

    describe 'When removing all files from a collection' do
      before do
        db_item_actions_toggle(collection).click
        click_link 'Edit Collection'
        page.should have_content file_1.title.first
        page.should have_content file_2.title.first
        check 'check_all'
        click_button 'Remove From Collection'
      end

      specify 'I should see that the collection is empty' do
        page.should have_content title
        page.should have_content description
        page.should_not have_content file_1.title.first
        page.should_not have_content file_2.title.first
      end
    end
  end
end