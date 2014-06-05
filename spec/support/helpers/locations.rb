module Locations
  def go_to_dashboard
    visit '/'
    first('a.dropdown-toggle').click
    click_link('my dashboard')
    # causes selenium to wait until text appears on the page
    page.should have_content('My Dashboard')
  end

  def go_to_dashboard_files
    go_to_dashboard
    click_link('View Files')
    expect(page).to have_selector('li.active', text:"Files")
  end

  def go_to_dashboard_collections
    go_to_dashboard_files
    click_link('Collections')
    page.should have_content('Collections')
  end

  def go_to_dashboard_shares
    go_to_dashboard_files
    click_link('Shared with Me')
    page.should have_content('Shared with Me')
  end

  def go_to_dashboard_highlights
    go_to_dashboard_files
    click_link('Highlighted')
    page.should have_content('Highlighted')
  end

end

RSpec.configure do |config|
  config.include Locations
end
