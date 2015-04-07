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
    let!(:gf) do
      GenericFile.new.tap do |gf|
        gf.title = ["jill's files"]
        gf.filename = ['test.pdf']
        gf.read_groups = ['public']
        gf.apply_depositor_metadata("jilluser")
        gf.save!
      end
    end

    let!(:gf2) do
      GenericFile.new.tap do |gf|
        gf.title = ["jill's shared file"]
        gf.filename = ['test.pdf']
        gf.permissions << Hydra::AccessControls::Permission.new(type: 'person', name: current_user.user_key, access: 'edit')
        gf.apply_depositor_metadata("jilluser")
        gf.save!
      end
    end

    scenario 'does not display collections and others files' do
      go_to_dashboard_shares
      expect(page).to_not have_content(collection_title)
      expect(page).to_not have_content(gf.title[0])
      expect(page).to have_content(gf2.title[0])
    end
  end

end
