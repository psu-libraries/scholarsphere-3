# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard
include Selectors::EditCollections

describe Collection, type: :feature do
  let(:current_user) { create(:user) }
  let(:work1)        { create(:work, depositor: current_user.login, title: ['world.png']) }
  let(:work2)        { create(:work, depositor: current_user.login, title: ['little_file.txt']) }

  before { sign_in_with_js(current_user) }

  context "when the collection has files" do
    let!(:collection) { create(:collection, depositor: current_user.login, members: [work1, work2]) }
    let!(:work3)      { create(:work, title: ['scholarsphere_test5.txt'], depositor: current_user.login) }

    describe 'adding an additional file' do
      specify do
        visit '/dashboard/works'
        db_file_checkbox(work3).click
        click_button 'Add to Collection'
        db_collection_radio_button(collection).click
        within("#collection-list-container .modal-footer") do
          click_button 'Add to Collection'
        end
        expect(page).to have_content 'Collection was successfully updated.'
        expect(page).to have_content work3.title.first
      end
    end
    describe 'removing a work' do
      specify do
        visit '/dashboard/collections'
        db_item_actions_toggle(collection).click
        click_link 'Edit Collection'
        expect(page).to have_content work1.title.first
        expect(page).to have_content work2.title.first
        db_item_actions_toggle(work1).click
        click_button 'Remove from Collection'
        expect(page).to have_content collection.title
        expect(page).to have_content collection.description
        expect(page).not_to have_content work1.title.first
        expect(page).to have_content work2.title.first
      end
    end
    describe 'removing all works' do
      specify do
        visit '/dashboard/collections'
        db_item_actions_toggle(collection).click
        click_link 'Edit Collection'
        expect(page).to have_content work1.title.first
        expect(page).to have_content work2.title.first
        check 'check_all'
        click_button 'Remove From Collection'
        expect(page).to have_content collection.title
        expect(page).to have_content collection.description
        expect(page).not_to have_content work1.title.first
        expect(page).not_to have_content work2.title.first
      end
    end
  end

  describe "editing a collection's metadata" do
    let!(:collection)           { create(:collection, depositor: current_user.login) }
    let!(:original_title)       { collection.title }
    let!(:original_description) { collection.description }

    let(:updated_title)         { 'Updated Title' }
    let(:updated_description)   { 'Updtaed description text.' }
    let(:updated_creators)      { ['Dorje Trollo', 'Vajrayogini'] }

    specify do
      visit '/dashboard/collections'
      db_item_actions_toggle(collection).click
      click_link 'Edit Collection'
      expect(page).to have_field 'collection_title', with: original_title
      expect(page).to have_field 'collection_description', with: original_description
      fill_in 'Title', with: updated_title
      fill_in 'Description', with: updated_description
      fill_in 'Creator', with: updated_creators.first
      ec_update_submit.click
      expect(page).not_to have_content original_title
      expect(page).not_to have_content original_description
      expect(page).to have_content updated_title
      expect(page).to have_content updated_description
      expect(page).to have_content updated_creators.first
    end
  end
end
