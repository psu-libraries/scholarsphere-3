# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares', type: :feature do
  let(:current_user) { create(:user) }
  let(:jill)         { create(:jill) }

  context "the default" do
    before do
      sign_in_with_js(current_user)
      go_to_dashboard_shares
    end

    it 'displays tab title and buttons' do
      expect(page).to have_content("Files Shared with Me")
      within('#sidebar') do
        expect(page).to have_content("Upload")
        expect(page).to have_content("Create Collection")
        expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
      end
    end
  end

  context 'when user has a collection' do
    let!(:collection) { create(:collection, depositor: current_user.user_key) }
    let!(:gf) { create(:public_file, title: ["Public, unshared file"], depositor: jill.user_key) }

    let!(:gf2) do
      create(:private_file,
             title: ["Private, shared filed"],
             depositor: jill.user_key,
             edit_users: [current_user.user_key]
            )
    end

    before do
      sign_in_with_js(current_user)
      go_to_dashboard_shares
    end

    it 'does not display collections and others files' do
      expect(page).to_not have_content(collection.title)
      expect(page).to_not have_content(gf.title.first)
      expect(page).to have_content(gf2.title.first)
    end
  end
end
