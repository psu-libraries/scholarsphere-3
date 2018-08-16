# frozen_string_literal: true

require 'feature_spec_helper'

describe GenericWork, js: true do
  let(:admin) { create(:administrator) }

  before { login_as admin }

  context 'when an administrator changes the depositor' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    let!(:work) do
      create(:public_work, :with_required_metadata, :with_one_file,
        depositor: user1.user_key,
        admin_set: AdminSet.first)
    end

    it 'updates the work with the new depositor' do
      visit("/concern/generic_works/#{work.id}/edit")
      expect(page).to have_field('generic_work[depositor]', with: user1.user_key)
      fill_in 'generic_work[depositor]', with: user2.user_key
      click_button('Save')
      expect(page).to have_content('Apply changes to contents?')
      click_button('Yes please.')
      expect(page).to have_content(work.title.first)
      work.reload
      expect(work.depositor).to eq(user2.user_key)
      expect(work.file_sets.first.depositor).to eq(user2.user_key)
      expect(work.edit_users).to contain_exactly(user2.user_key)
      expect(work.file_sets.first.edit_users).to contain_exactly(user2.user_key)
    end
  end
end
