# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Collections:', type: :feature do
  let!(:jill_collection) { create(:collection, title: ["Jill's Collection"], depositor: jill.login) }
  let!(:collection)      { create(:collection, creators: [creator], depositor: current_user.login) }

  let(:creator)      { create(:alias, :with_agent) }
  let(:current_user) { create(:user) }
  let(:jill)         { create(:jill) }

  before do
    sign_in_with_js(current_user)
    go_to_dashboard_collections
  end

  it 'checks the page' do
    # tab title and buttons
    expect(page).to have_content('My Collections')
    expect(page).not_to have_content('Object Type')
    expect(page).to have_link('New Work', visible: false) # link is there (even if collapsed)
    expect(page).to have_link('New Collection', visible: false) # link is there (even if collapsed)
    expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")

    # collections are displayed in the Collections list
    expect(page).to have_content collection.title.first
    expect(page).not_to have_content jill_collection.title

    # displays the correct totals for each facet
    within('#facets') do
      click_link('Creator')
      expect(page).to have_content('Given Name Sur Name')
    end

    # additional information is hidden by default
    expect(page).not_to have_content(creator.display_name)
    expect(page).not_to have_content(collection.depositor)
    expect(page).not_to have_content 'Edit Access'
    expect(page).not_to have_content(current_user)

    # toggle displays additional information
    first('span.glyphicon-chevron-right').click
    expect(page).to have_content(creator.display_name)
    expect(page).to have_content(collection.depositor)
    expect(page).to have_content 'Edit Access'
    expect(page).to have_content(current_user)

    # toggle additional actions
    expect(page).not_to have_content('Edit Collection')
    expect(page).not_to have_content('Delete Collection')
    within('#documents') do
      first('.btn.dropdown-toggle').click
    end
    expect(page).to have_content('Edit Collection')
    expect(page).to have_content('Delete Collection')

    # collections are not displayed in the Works list
    go_to_dashboard_works
    expect(page).not_to have_content collection.title
  end
end
