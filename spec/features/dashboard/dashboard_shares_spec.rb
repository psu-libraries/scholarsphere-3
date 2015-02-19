require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares', :type => :feature do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
  end

  scenario 'tab title and buttons' do
    go_to_dashboard_shares
    expect(page).to have_content("Files Shared with Me")
    within('#sidebar') do
      expect(page).to have_content("Upload")
      expect(page).to have_content("Create Collection")
      expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
    end
  end

  context 'when user has a collection' do
    let(:collection_title) { 'My interesting collection' }
    let!(:my_collection) {
      Collection.new(title: collection_title).tap do |c|
        c.apply_depositor_metadata(current_user.user_key)
        c.save!
      end
    }

    scenario 'does not display collections' do
      go_to_dashboard_shares
      expect(page).to_not have_content(collection_title)
    end
  end

end
