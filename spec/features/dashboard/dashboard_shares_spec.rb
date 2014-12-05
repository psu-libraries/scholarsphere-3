require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares', :type => :feature do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard_shares
  end

  specify 'tab title and buttons' do
    expect(page).to have_content("Files Shared with Me")
    within('#sidebar') do
      expect(page).to have_content("Upload")
      expect(page).to have_content("Create Collection")
      expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
    end
  end

end
