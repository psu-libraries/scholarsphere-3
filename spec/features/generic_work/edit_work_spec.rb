# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Editing a work' do
  let(:proxy) { create(:first_proxy) }
  let(:user)  { create(:user, :with_proxy, proxy_for: proxy) }
  let(:work)  { create(:public_work, :with_required_metadata, depositor: user.user_key) }

  before { sign_in(user) }

  # Tests the basic outline of the form. This can be expanded later with more detail including
  # refactoring it to incorporate other tests.
  it 'displays the edit form' do
    visit("/concern/generic_works/#{work.id}/edit")
    within('.base-terms') do
      expect(page).to have_selector('h2', text: 'Basic Metadata')
      expect(page).to have_selector('label', text: 'Subtitle')
    end

    within('#work-media') do
      expect(page).to have_selector('h2', text: 'Media')
    end

    within('#extended-terms') do
      expect(page).to have_selector('h2', text: 'Additional Metadata', visible: false)
    end

    expect(page).not_to have_selector('#generic_work_on_behalf_of')
  end
end
