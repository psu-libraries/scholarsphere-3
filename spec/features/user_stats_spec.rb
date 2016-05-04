# frozen_string_literal: true
require 'feature_spec_helper'

describe "User Statistics", type: :feature do
  let!(:user) { create(:user) }

  before do
    sign_in(user)
    # More than 10 times, because the pagination threshold is 10
    12.times { create(:file_set, user: user) }
    UserStat.create!(user_id: user.id, date: Date.today, file_views: 11, file_downloads: 6)
  end
  it "includes file deposited, viewed, and downloaded, as well as followers" do
    visit "/dashboard"
    expect(page).to have_selector('span.badge', text: "12")
    expect(page).to have_content('11 Views')
    expect(page).to have_content('6 Downloads')
    expect(page).to have_content('Follower(s): 0')
    expect(page).to have_content('Following: 0')
  end
end
