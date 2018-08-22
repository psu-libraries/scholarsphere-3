# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Administrative Statistics', type: :feature do
  let(:user)  { create(:user) }
  let(:admin) { create(:administrator) }

  before do
    3.times { create(:public_work, depositor: user.login) }
    sign_in(admin)
  end

  it 'displays the administrative statistics and emails reports' do
    visit '/admin/stats'
    expect(page).to have_selector('h2', text: 'Statistics By Date')
    expect(page).to have_selector('h3', text: 'Work Statistics')
    expect(page).to have_selector('h4', text: 'Total Works: 3')
  end
end
