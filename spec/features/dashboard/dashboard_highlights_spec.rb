require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Highlights' do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
    go_to_dashboard_highlights
  end  

  specify 'tab title and buttons' do
    page.should have_content("My Highlights")
    within('.col-xs-12.col-sm-3') do
      page.should have_content("Upload")
      page.should have_content("Create Collection")
    end
  end

end
