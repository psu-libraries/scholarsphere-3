require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Collection creation and deletion:', type: :feature do
  let!(:current_user) { create :user }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }

  before do
    sign_in_as current_user
  end

  describe 'When creating an empty collection' do
    before do
      go_to_dashboard
      db_create_empty_collection_button.click
      create_collection [title], creator, [description]
    end

    specify 'I should see the new collection page' do
      expect(page).to have_content 'Collection was successfully created.'
    end
  end

  let(:filenames) { %w{world.png small_file.txt} }
  let(:files) { GenericFile.all }

  describe 'When creating a collection with files' do
    before do
      filenames.each do |filename|
        create_file current_user, { title: [filename], creator: "#{filename}_creator" }
      end
      go_to_dashboard_files
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection [title], creator, [description]
    end

    specify 'I should see the collection page with the files' do
      expect(page).to have_content 'Collection was successfully created.'
      files.each do |file|
        expect(page).to have_content file.title.first
      end
    end
  end

  let(:collection) { Collection.first }

  describe 'When deleting a collection' do
    before do
      visit '/dashboard'
      db_create_empty_collection_button.click
      create_collection [title], creator, [description]
      visit '/dashboard/collections'
      db_item_actions_toggle(collection).click
      click_link 'Delete Collection'
    end

    specify 'I should no longer see it on my dashboard' do
      expect(page).to have_content 'Collection was successfully deleted'
      expect(page).to have_css '#documents'
      expect(page).not_to have_content title
    end
  end
end
