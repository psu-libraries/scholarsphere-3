# frozen_string_literal: true
require "feature_spec_helper"

include Selectors::Dashboard

describe "Dashboard Highlights", type: :feature do
  let(:current_user) { create(:user) }

  before do
    sign_in(current_user)
    go_to_dashboard_highlights
  end

  specify "tab title and buttons" do
    expect(page).to have_content("My Highlights")
    expect(page).to have_content("New Work")
    expect(page).to have_content("Create Collection")
    expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
  end
end
