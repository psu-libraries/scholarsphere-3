# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Administrative Statistics', type: :feature do
  let(:user)  { create(:user) }
  let(:admin) { create(:administrator) }
  let(:email) { UserMailer.stats_email(8.days.ago.beginning_of_day, 1.day.ago.end_of_day) }

  before do
    3.times do |count|
      create(:work, :with_one_file,
        title: ["Admin Stat Work #{count}"],
        date_uploaded: (Date.today - count.week),
        depositor: user.login)
    end
    sign_in(admin)
  end

  it 'displays the administrative statistics and emails reports' do
    visit '/admin/stats'
    expect(page).to have_selector('h2', text: 'Statistics By Date')
    expect(page).to have_selector('h3', text: 'Work Statistics')
    expect(page).to have_selector('h4', text: 'Total Works: 3')
    expect(email.message.parts.last.body.raw_source).to include('Admin Stat Work 1')
    expect(email.message.parts.last.body.raw_source).not_to include('Admin Stat Work 0')
    expect(email.message.parts.last.body.raw_source).not_to include('Admin Stat Work 2')
  end
end
