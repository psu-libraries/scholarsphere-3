# frozen_string_literal: true

require 'feature_spec_helper'

include Selectors::Dashboard

describe 'Dashboard Shares', type: :feature, js: true do
  let(:current_user) { create(:user) }
  let(:jill)         { create(:jill) }

  let!(:collection) { create(:collection, depositor: current_user.user_key) }
  let!(:gf)         { create(:public_file, title: ['Public, unshared file'], depositor: jill.user_key) }

  let!(:gf2) do
    create(:private_file, title: ['Private, shared filed'],
                          depositor: jill.user_key,
                          edit_users: [current_user.user_key])
  end

  before do
    login_as(current_user)
    go_to_dashboard_shares
  end

  it 'displays only shared files' do
    expect(page).to have_content('Shared with Me')
    expect(page).to have_content('Object Type')
    expect(page).to have_link('New Work', visible: false)
    expect(page).to have_link('New Collection', visible: false)
    expect(page).not_to have_selector(".batch-toggle input[value='Delete Selected']")
    expect(page).not_to have_content(collection.title)
    expect(page).not_to have_content(gf.title.first)
    expect(page).to have_content(gf2.title.first)
    within("tr#document_#{gf2.id}") do
      expect(page).to have_link('Edit Work')
    end
  end
end
