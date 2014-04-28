# This file is a Work in Progress


require_relative './feature_spec_helper'

include Selectors::Dashboard

describe 'Collections:' do

  let(:current_user) { create :user }
  let(:filenames) { %w{world.png small_file.txt} }
  let(:title1) { 'Test Collection 1' }
  let(:creator) { 'Test Creator' }
  let(:description1) { 'Description for collection 1 we are testing.' }
  let(:title2) { 'Test Collection 2' }
  let(:description2) { 'Description for collection 2 we are testing.' }

  before do
    sign_in_as current_user
    filenames.each do |filename|
      upload_generic_file filename
    end
  end

  let(:files) { GenericFile.all }
  let(:file_1) { GenericFile.first }
  let(:file_2) { GenericFile.last }

  describe 'When creating a collection:' do

    specify 'I should be able to create it without any files' do
      db_create_collection_button.click
      create_collection title1, creator, description1
    end

    specify 'I should be able to create it with files' do
      check 'check_all'
      click_button 'Add to Collection'
      click_button 'Add to new Collection'
      create_collection title1, creator, description1
      files.each do |file|
        page.should have_content file.title.first
      end
    end
  end

  describe 'When deleting a collection:' do
    before do
      @collection = Collection.new title: 'collection title 1'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata current_user.user_key
      @collection.save!
    end

    specify 'I should no longer see it on my dashboard' do
      page.should have_content @collection.title
      db_item_actions_toggle(@collection).click
      click_link 'Delete Collection'
      page.should have_content 'Collection was successfully deleted'
      page.should have_content 'Dashboard'
      page.should_not have_content @collection.title
    end
  end

  describe 'When viewing a collection:' do
    before do
      @collection = Collection.new title: 'collection title 2'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata current_user.user_key
      @collection.members = [file_1, file_2]
      @collection.save!
    end

    it 'I should see its metadata' do
      page.should have_content @collection.title
      db_item_title(@collection).click
      page.should have_content @collection.title
      page.should have_content @collection.description
      # Should not have Collection Descriptive metadata table
      page.should have_content 'Descriptions'
      # Should have search results / contents listing
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
    end
  end

  describe 'When searching within a collection' do
    before do
      @collection = Collection.new title: 'collection title 3'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata current_user.user_key
      @collection.members = [file_1, file_2]
      @collection.save!
    end
    specify 'I should see the correct results' do
      page.should have_content @collection.title
      db_item_title(@collection).click
      page.should have_content @collection.title
      page.should have_content @collection.description
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
      fill_in('collection_search', with: file_1.title.first)
      click_button 'collection_submit'
      # Should not have Collection Descriptive metadata table
      page.should_not have_content 'Descriptions'
      page.should have_content @collection.title
      page.should have_content @collection.description
      # Should have search results / contents listing
      page.should have_content file_1.title.first
      page.should_not have_content file_2.title.first
      # Should not have Dashboard content in contents listing
      page.should_not have_content 'Visibility'
    end
  end

  describe 'When updating a collection:' do
    before do
      @collection = Collection.new title: 'collection title'
      @collection.description = 'collection description'
      @collection.apply_depositor_metadata current_user.user_key
      @collection.members = [file_1, file_2]
      @collection.save!
    end

    specify 'I should be able to add files to it' do
      pending 'Werk aint dun yet!'
    end

    specify 'I should be able to update its metadata' do
      page.should have_content @collection.title
      db_item_actions_toggle(@collection).click
      click_link 'Edit Collection'
      page.should have_field 'collection_title', with: @collection.title
      page.should have_field 'collection_description',
          with: @collection.description
      new_title = 'Altered Title'
      new_description = 'Completely new description text.'
      creators = ['Dorje Trollo', 'Vajrayogini']
      fill_in 'Title', with: new_title
      fill_in 'Description', with: new_description
      fill_in 'Creator', with: creators.first
      within '.span68' do
        within '.form-actions' do
          click_button 'Update Collection'
        end
      end
      page.should_not have_content @collection.title
      page.should_not have_content @collection.description
      page.should have_content new_title
      page.should have_content new_description
      page.should have_content creators.first
    end

    specify 'I should be able to remove a file from it' do
      page.should have_content @collection.title
      db_item_actions_toggle(@collection).click
      click_link 'Edit Collection'
      page.should have_field 'collection_title', with: @collection.title
      page.should have_field 'collection_description',
          with: @collection.description
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
      db_item_actions_toggle(@collection).click
      click_link 'Remove from Collection'
      page.should have_content @collection.title
      page.should have_content @collection.description
      page.should_not have_content file_1.title.first
      page.should have_content file_2.title.first
    end

    specify 'I should be able to remove all files it' do
      page.should have_content @collection.title
      db_item_actions_toggle(@collection).click
      click_link 'Edit Collection'
      page.should have_field 'collection_title', with: @collection.title
      page.should have_field 'collection_description',
          with: @collection.description
      page.should have_content file_1.title.first
      page.should have_content file_2.title.first
      check 'check_all'
      click_button 'Remove From Collection'
      page.should have_content @collection.title
      page.should have_content @collection.description
      page.should_not have_content file_1.title.first
      page.should_not have_content file_2.title.first
    end
  end
end