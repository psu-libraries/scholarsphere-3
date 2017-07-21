# frozen_string_literal: true
require "feature_spec_helper"

describe "Visting the home page:", type: :feature do
  let!(:content_block) { create(:marketing_text) }

  before do
    sign_in_with_js(current_user)
    visit "/"
  end

  subject { page }

  context "and I do not belong to any groups" do
    let(:current_user) { create(:user) }
    it { is_expected.to have_content("Share. Manage. Preserve.") }
  end

  context "and I belong to a couple of groups" do
    let(:current_user) { create(:user, :with_two_groups) }
    it do
      is_expected.to have_content("Share. Manage. Preserve.")
      is_expected.to have_content(current_user.display_name)
    end
  end

  context "and I belong to a lot of groups" do
    let(:current_user) { create(:user, :with_many_groups) }
    it do
      # pending("Causes error RSolr::Error::Http - 414 Request-URI Too Long Error")
      is_expected.to have_content("Share. Manage. Preserve.")
      is_expected.to have_content(current_user.display_name)
    end
  end

  context "with a mobile device" do
    let(:current_user) { create(:user) }
    before { page.driver.browser.resize(400, 500) }
    it { is_expected.not_to have_content(current_user.display_name) }
  end
end
