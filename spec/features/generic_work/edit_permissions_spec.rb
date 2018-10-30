# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Editing permissions on a work', js: true do
  context 'when removing permissions from a work with files' do
    let(:user1) { create(:user, display_name: 'First User') }
    let(:user2) { create(:user, display_name: 'Second User') }
    let(:work) do
      create(:public_work, :with_required_metadata, depositor: user1.user_key,
                                                    edit_users: [user1.user_key, user2.user_key])
    end

    let(:file_set) { create(:file_set, :public, user: user1, edit_users: [user1.user_key, user2.user_key]) }

    before do
      work.members << file_set
      work.save
      login_as user1
    end

    it 'copies the permissions to the file set' do
      visit("/concern/generic_works/#{work.id}/edit")
      within('ul.nav-tabs') do
        click_link('Collaborators')
      end
      within('#share') do
        expect(page).to have_content('First User')
        expect(page).to have_content('Second User')
      end
      find('.remove_perm').click
      click_button('Save')
      expect(page).to have_content('Apply changes to contents?')
      click_button('Yes please.')
      expect(page).to have_content(work.title.first)
      expect(work.reload.edit_users).to contain_exactly(user1.user_key)
      expect(work.file_sets.first.edit_users).to contain_exactly(user1.user_key)
    end
  end
end
