# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature do
  let(:current_user) { create(:user) }
  let(:title) { 'Test Collection Title' }

  before { sign_in_with_js(current_user) }

  describe 'deleting a collection' do
    let!(:collection) { create(:collection, depositor: current_user.login) }

    it 'removes it on my dashboard' do
      visit '/dashboard/collections'
      db_item_actions_toggle(collection).click
      click_link 'Delete Collection'
      expect(page).to have_content 'Collection was successfully deleted'
      within("#my_nav") do
        expect(page).to have_content("My Collections")
      end
      within("#documents") do
        expect(page).not_to have_content title
      end
    end
  end
end
