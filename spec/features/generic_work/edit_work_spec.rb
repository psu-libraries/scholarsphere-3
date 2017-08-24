# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

describe 'Editing a work', js: true do
  let(:proxy) { create(:first_proxy) }
  let(:user)  { create(:user, :with_proxy, proxy_for: proxy) }
  let(:work)  { create(:public_work, :with_required_metadata, depositor: user.user_key, creators: [sally, yuki]) }
  let(:sally) { create(:creator, first_name: 'Sally', last_name: 'Henry') }
  let(:yuki) { create(:creator, first_name: 'Yuki', last_name: 'Matsumoto') }

  before { login_as user }

  it 'saves the updates' do
    visit("/concern/generic_works/#{work.id}/edit")

    # There are 2 existing creators, "Sally" and "Yuki"
    expect(page).to have_selector('.creator_inputs', count: 2)

    # Remove existing creator "Sally"
    sally_remove_button = find(:xpath, './/button[../input[@value="Sally"]]')
    sally_remove_button.click
    expect(page).to have_selector('.creator_inputs', count: 1)

    # Add a new creator "Verity".
    click_button 'Add another Creator'
    expect(page).to have_selector('.creator_inputs', count: 2)

    # The index should be 'generic_work[creators][2]' because
    # '0' and '1' were already used by Sally and Yuki.
    fill_in 'generic_work[creators][2][first_name]', with: 'Verity'
    fill_in 'generic_work[creators][2][last_name]', with: 'Brown'
    click_button 'Save'

    # The updated creator data should appear on the show page
    expect(page).not_to have_link 'Sally Henry'
    expect(page).to     have_link 'Verity Brown'
    expect(page).to     have_link 'Yuki Matsumoto'

    # The persisted work should have the updated creator data
    work.reload
    expect(work.creators.map(&:first_name)).to contain_exactly('Verity', 'Yuki')
  end

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

    find('.additional-fields').click
    within('#extended-terms') do
      expect(page).to have_selector('h2', text: 'Additional Metadata')
    end

    expect(page).not_to have_selector('#generic_work_on_behalf_of')
  end
end
