require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares' do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard_shares
  end

  specify 'tab title and buttons' do
    page.should have_content("Files Shared with Me")
    within('#sidebar') do
      page.should have_content("Upload")
      page.should have_content("Create Collection")
    end
  end

end
