require_relative '../feature_spec_helper'

include Selectors::Dashboard
include Selectors::EditCollections

describe 'Collection editing:' do

  let!(:current_user) { create :user }
  #TODO why can this not be small_file.txt??
  #let(:filenames) { %w{world.png little_file.txt scholarsphere_test5.txt} }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }
  let!(:file_1) { create_file current_user, {title:'world.png'} }
  let!(:file_2) { create_file current_user, {title:'little_file.txt'} }
  let!(:file_3) { create_file current_user, {title:'scholarsphere_test5.txt'} }
  let(:collection) { Collection.first }

  before do
    sign_in_as current_user
    go_to_dashboard_files
    db_file_checkbox(file_1).click
    db_file_checkbox(file_2).click
    click_button 'Add to Collection'
    db_create_populated_collection_button.click
    create_collection title, creator, description
    visit '/dashboard/files'
  end

  describe 'When adding a file to a collection' do
    before do
      db_file_checkbox(file_3).click
      click_button 'Add to Collection'
      db_collection_radio_button(collection).click
      click_button 'Add to Collection'
    end

    specify 'I should see the new file in the collection' do
      page.should have_content 'Collection was successfully updated.'
      page.should have_content file_3.title.first
    end
  end

  describe "When editing a collection's metadata" do

    let(:updated_title) { 'Updated Title' }
    let(:updated_description) { 'Updtaed description text.' }
    let(:updated_creators) { ['Dorje Trollo', 'Vajrayogini'] }

    before do
      visit '/dashboard/collections'
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
      visit '/dashboard/collections'
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
      visit '/dashboard/collections'
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