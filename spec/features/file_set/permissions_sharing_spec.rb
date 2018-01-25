# frozen_string_literal: true

require 'feature_spec_helper'

describe 'PermissionsSharing:', type: :feature do
  let(:work)         { create(:public_work_with_png, file_title: ['stonehenge star people'], depositor: current_user.login) }
  let(:current_user) { create(:user) }
  let(:file_set)     { work.file_sets.first }
  let(:filename)     { '4-20-small.png' }

  before do
    sign_in(current_user)
    visit "/concern/file_sets/#{file_set.id}"
  end

  it 'ensures that content still retains a good document outline for accessibility' do
    click_link('Edit This File')
    expect(page).to have_selector('h3', text: 'Permission Definitions')
    expect(page).to have_selector('dt', text: 'View/Download')
    expect(page).to have_selector('h2', text: 'Share file with other users')
    expect(page).to have_selector('h2', text: 'Share file with groups of users')
    expect(page).to have_selector('h2', text: 'Sharing With')
  end
end
