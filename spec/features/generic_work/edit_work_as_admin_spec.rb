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

      # Only show the depositor field, and not on_behalf_of because it is empty.
      # We don't want to enable this field because putting a value in it would effect a transfer.
      expect(page).to have_field('generic_work[depositor]', with: user1.user_key)
      expect(page).not_to have_field('generic_work[on_behalf_of]')

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

  context 'when an administrator changes the on-behalf-of user' do
    let(:proxy)       { create(:user, login: 'proxy1', display_name: 'Original Proxy Depositor') }
    let(:first_user)  { create(:user, login: 'obu1', display_name: 'Original On-Behalf-Of User') }
    let(:new_proxy)   { create(:user, login: 'proxy2', display_name: 'New Proxy Depositor') }
    let(:second_user) { create(:user, login: 'obu2', display_name: 'New On-Behalf-Of User') }

    # This is a work with the depositor creating on behalf of another user. When the work is saved,
    # this initiates an immediate transfer so that the "on behalf of" user becomes the depositor.
    let!(:work) do
      create(:public_work, :with_required_metadata, :with_one_file,
        depositor: proxy.user_key,
        on_behalf_of: first_user.user_key,
        admin_set: AdminSet.first)
    end

    it 'updates the work with the a new depositor' do
      visit("/concern/generic_works/#{work.id}/edit")

      # @note There is some confusion about whether or not depositor and on_behalf_of should be the
      #   the same. We're assuming that they should be because the current code seems to reflect this.
      # @see https://github.com/psu-stewardship/scholarsphere/issues/978

      # Only on_behalf_is shown because GenericWorkActor#apply_save_data_to_curation_concern always
      # sets the depositor to the value of the on_behalf_of user, so the field should not be shown
      # if a value exists for on_behalf_of
      expect(page).not_to have_field('generic_work[depositor]')
      expect(page).to have_field('generic_work[on_behalf_of]', with: first_user.user_key)

      # Verify permissions
      # @todo the on-behalf-of user does not have edit access. This should probably be a bug
      # expect(work.edit_users).to contain_exactly(proxy.user_key, first_user.user_key)

      fill_in 'generic_work[on_behalf_of]', with: second_user.user_key

      click_button('Save')
      expect(page).to have_content('Apply changes to contents?')
      click_button('Yes please.')
      expect(page).to have_content(work.title.first)
      work.reload
      expect(work.depositor).to eq(second_user.user_key)
      expect(work.file_sets.first.depositor).to eq(second_user.user_key)
      expect(work.edit_users).to contain_exactly(proxy.user_key, second_user.user_key)
      expect(work.file_sets.first.edit_users).to contain_exactly(proxy.user_key, second_user.user_key)
    end
  end
end
