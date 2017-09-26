# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe 'The Dashboard', type: :feature do
  let(:user) { create(:user) }

  describe 'a user who has files and collections' do
    let!(:work)         { create(:public_work, :with_one_file, depositor: user.user_key) }
    let!(:collection)   { create(:collection, depositor: user.user_key) }

    before do
      sign_in(user)
      go_to_dashboard
    end

    it "shows the user's statistics" do
      expect(page).to have_content(user.display_name)
      expect(page).to have_content('1 Works created')
      expect(page).to have_content('1 Collections created 1')
    end
  end

  describe 'a user without files and collections' do
    before do
      sign_in(user)
      go_to_dashboard
    end
    it 'displays information correctly' do
      # displays information about the user
      expect(page).to have_content 'Joe Example'
      expect(page).to have_link 'View Profile'
      expect(page).to have_link 'Edit Profile'
      expect(page).to have_content('0 Works created')
      expect(page).to have_content('0 Collections created')

      # shows recent activity
      expect(page).to have_content 'User Activity'
      expect(page).to have_content 'User has no recent activity'
    end
  end

  describe 'a user with multiple current proxies' do
    let!(:first_proxy)  { create(:first_proxy) }
    let!(:second_proxy) { create(:second_proxy) }

    before do
      sign_in_with_js(user)
      go_to_dashboard
      create_proxy_using_partial(first_proxy, second_proxy)
    end

    it 'lists each proxy if both are authorized' do
      within('#authorizedProxies') do
        expect(page).to have_content(first_proxy.display_name)
        expect(page).to have_content(second_proxy.display_name)
      end
      go_to_dashboard
      within('#authorizedProxies') do
        expect(page).to have_content(first_proxy.display_name)
        expect(page).to have_content(second_proxy.display_name)
      end

      # should remove a proxy
      first('.remove-proxy-button').click
      sleep(1.second)
      go_to_dashboard
      within('#authorizedProxies') do
        expect(page).to have_content(second_proxy.display_name)
        expect(page).not_to have_content(first_proxy.display_name)
      end
    end
  end

  describe 'a user with transfers' do
    let(:another_user) { create(:jill) }

    context 'with no transfers' do
      before do
        sign_in(user)
        go_to_dashboard
      end

      it 'shows no transfers' do
        within('div#transfers') do
          expect(page).to have_link('Select works to transfer')
          expect(page).to have_content "You haven't transferred any work"
          expect(page).to have_content "You haven't received any work transfer requests"
        end
      end
    end

    context 'with one incoming' do
      let!(:incoming_file) { create(:file, depositor: another_user.user_key, transfer_to: user) }

      before do
        sign_in(user)
        go_to_dashboard
      end

      it 'displays received files' do
        within('#incoming-transfers') do
          expect(page).to have_link another_user.name
          expect(page).to have_content 'less than a minute ago'
          expect(page).to have_button 'Accept'
        end
      end
    end

    context 'with one outgoing' do
      let!(:outgoing_file) { create(:file, depositor: user.user_key, transfer_to: another_user) }

      before do
        sign_in(user)
        go_to_dashboard
      end

      it 'displays files sent to another user' do
        within('#outgoing-transfers') do
          expect(page).to have_link another_user.name
          expect(page).to have_content 'less than a minute ago'
          expect(page).to have_button 'Cancel'
        end
      end
    end
  end
end
