# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Showing recent additions', type: :feature do
  let(:current_user) { create(:user) }
  let!(:gf)          { create(:public_file, depositor: current_user.login, keyword: ["'55 Chet Atkins"]) }

  it 'shows the correct links to facets' do
    visit '/'
    click_link 'Recent Additions'
    expect(page).to have_selector('h3', gf.title.first)
    click_link(gf.keyword.first)
    expect(page).to have_selector('h1', gf.title.first)
  end
end
