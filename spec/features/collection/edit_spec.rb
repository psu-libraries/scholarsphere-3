# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature do
  let(:current_user) { create(:user) }
  let(:work1)        { create(:work, depositor: current_user.login, title: ['world.png']) }
  let(:work2)        { create(:work, depositor: current_user.login, title: ['little_file.txt']) }

  context "when the collection has files" do
    let!(:collection) { create(:collection, depositor: current_user.login, members: [work1, work2], description: ["my description"]) }
    let!(:work3)      { create(:work, title: ['scholarsphere_test5.txt'], depositor: current_user.login) }

    before { sign_in_with_js(current_user) }

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
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first
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
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first
        expect(page).not_to have_content work1.title.first
        expect(page).not_to have_content work2.title.first
      end
    end
  end

  describe "editing a collection's metadata" do
    let!(:collection)           { create(:collection, depositor: current_user.login, description: ["original description"]) }
    let!(:original_title)       { collection.title }
    let!(:original_description) { collection.description }

    let(:updated_title)         { 'Updated Title' }
    let(:updated_description)   { 'Updtaed description text.' }
    let(:updated_creators)      { ['Dorje Trollo', 'Vajrayogini'] }

    before { sign_in(current_user) }

    specify do
      visit '/dashboard/collections'
      db_item_actions_toggle(collection).click
      click_link 'Edit Collection'
      click_link 'Additional fields'
      expect(page).to have_field 'collection_title', with: original_title.first
      expect(page).to have_field 'collection_description', with: original_description.first
      within("div.collection_date_created") do
        expect(page).to have_content("Published Date")
      end
      expect(page).to have_checked_field("Public")
      expect(page).to have_no_checked_field("Private")
      fill_in 'Title', with: updated_title
      fill_in 'Description', with: updated_description
      fill_in 'Creator', with: updated_creators.first
      click_button 'Update Collection'
      expect(page).not_to have_content original_title.first
      expect(page).not_to have_content original_description.first
      expect(page).to have_content updated_title
      expect(page).to have_content updated_description
      expect(page).to have_content updated_creators.first
    end
  end

  context "when adding works" do
    let(:collection) { create(:collection, depositor: current_user.login, title: ["Special collection"]) }

    before do
      sign_in_with_js(current_user)
      visit("/collections/#{collection.id}/edit")
    end

    describe 'adding existing works' do
      let!(:work4) { create(:work, depositor: current_user.login, title: ["Work to add"]) }
      specify do
        click_link("Add existing works")
        check "check_all"
        expect(page).to have_button("Add to #{collection.title.first}")
      end
    end

    describe 'adding new works' do
      specify do
        click_link("Add new works")
        expect(page).to have_content("Add Multiple New Works")
        within("ul.nav-tabs") { click_link("Collections") }
        expect(page).to have_select("batch_upload_item_collection_ids", selected: collection.title.first)
      end
    end
  end
end
