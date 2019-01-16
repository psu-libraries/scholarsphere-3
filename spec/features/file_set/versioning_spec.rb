# frozen_string_literal: true

require 'feature_spec_helper'

describe 'FileSet versioning:', type: :feature do
  let(:work)         { create(:public_work_with_png, file_title: ['Some work'], depositor: current_user.login) }
  let(:current_user) { create(:user) }
  let(:file_set)     { work.file_sets.first }
  let(:filename)     { '4-20-small.png' }

  before do
    sign_in(current_user)
    visit "/concern/file_sets/#{file_set.id}"
  end

  it 'sets the file set title and label to new and reverted file versions' do
    click_link('Edit This File')
    expect(page).to have_field('Title', with: 'world.png')
    expect(page).to have_button('Save')
    click_link('Versions')
    expect(page).not_to have_content('A PDF is preferred')
    attach_file('file_set[files][]', test_file_path(filename), visible: false)
    click_button('Upload New Version')
    expect(page).to have_selector('h1', text: filename)
    within('.file-show-details') do
      expect(page).to have_selector('dd', text: filename)
    end
    click_link('Edit This File')
    click_link('Versions')
    find('#revision_version1').set(true)
    click_button('Save Revision')
    expect(page).to have_selector('h1', text: 'world.png')
    within('.file-show-details') do
      expect(page).to have_selector('dd', text: 'world.png')
    end
  end
end
