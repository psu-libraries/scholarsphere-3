# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature do
  let!(:current_user) { create(:user) }
  let(:title) { 'Test Collection Title' }
  let(:creator) { 'Test Creator Name' }
  let(:description) { 'Description for our test collection.' }

  before do
    sign_in_with_js(current_user)
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

  describe 'when creating a collection with files' do
    let!(:file1) { create(:file, title: ["First file"], depositor: current_user.login) }
    let!(:file2) { create(:file, title: ["Second file"], depositor: current_user.login) }
    before do
      go_to_dashboard_works
      check 'check_all'
      click_button 'Add to Collection'
      db_create_populated_collection_button.click
      create_collection [title], creator, [description]
    end

    specify 'I should see the collection page with the files' do
      expect(page).to have_content 'Collection was successfully created.'
      expect(page).to have_content file1.title.first
      expect(page).to have_content file2.title.first
    end
  end

  context 'when deleting a collection' do
    let!(:collection) { create(:collection, depositor: current_user.login) }
    before do
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
