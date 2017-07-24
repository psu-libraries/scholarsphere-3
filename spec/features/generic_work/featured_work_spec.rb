# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Showing the Generic File', type: :feature do
  let(:current_user) { create(:administrator) }
  let!(:gf)          { create(:public_file, depositor: current_user.login) }

  it 'allows a feature to be marked and deleted' do
    sign_in_with_js(current_user)
    visit '/'
    click_link 'Recent Additions'
    expect(page).to have_content(gf.title.first)
    click_link gf.title.first
    expect(page).to have_content('Metadata')
    expect(page).to have_link 'Feature'
    click_link 'Feature'
    visit "/concern/generic_works/#{gf.id}" # force a page refresh
    expect(page).to have_content('Unfeature')
    visit '/'
    within('.new_featured_work_list') do
      expect(page).to have_content(gf.title[0])
      find('.glyphicon-remove').click
    end
    within('.new_featured_work_list') do
      expect(page).not_to have_content(gf.title[0])
    end
  end
end
