# frozen_string_literal: true
module Locations
  def go_to_dashboard
    visit '/dashboard'
    # causes selenium to wait until text appears on the page
    expect(page).to have_content('My Dashboard')
  end

  def go_to_dashboard_works
    visit '/dashboard/works'
    expect(page).to have_selector('li.active', text: "My Works")
  end

  def go_to_dashboard_collections
    # go_to_dashboard_files
    # click_link('My Collections')
    visit '/dashboard/collections'
    expect(page).to have_content('My Collections')
  end

  def go_to_dashboard_shares
    visit '/dashboard/shares'
  end

  def go_to_dashboard_highlights
    # go_to_dashboard_files
    # click_link('My Highlights')
    visit '/dashboard/highlights'
    expect(page).to have_content('My Highlights')
  end
end

RSpec.configure do |config|
  config.include Locations
end
