# frozen_string_literal: true
require 'feature_spec_helper'

describe "Editing a work" do
  let(:user1) { create(:user, display_name: "First User") }
  let(:work)  { create(:public_work, :with_required_metadata, depositor: user1.user_key) }

  before { sign_in(user1) }

  # Tests the basic outline of the form. This can be expanded later with more detail including
  # refactoring it to incorporate other tests.
  it "displays the edit form" do
    visit("/concern/generic_works/#{work.id}/edit")
    within(".base-terms") do
      expect(page).to have_selector("h2", text: "Required Metadata")
    end

    within("#work-media") do
      expect(page).to have_selector("h2", text: "Media")
      expect(page).to have_content(I18n.t('scholarsphere.media'))
    end

    within("#extended-terms") do
      expect(page).to have_selector("h2", text: "Additional Metadata", visible: false)
    end
  end
end
