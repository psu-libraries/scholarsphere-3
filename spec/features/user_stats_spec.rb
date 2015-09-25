require 'spec_helper'

describe "User Statistics", type: :feature do
  let!(:current_user) { create :administrator }
  let(:user_name) { current_user.login }

  before do
    sign_in_as current_user
  end

  context "deposited files" do
    before do
      # More than 10 times, because the pagination threshold is 10
      12.times do |_t|
        create_file current_user
      end
      UserStat.create!(user_id: current_user.id, date: Date.today, file_views: 11, file_downloads: 6)
      visit "/dashboard"
      expect(page).to have_content "Your Statistics"
    end
    it "includes the number of files deposited" do
      within('tr', text: "Files you've deposited") do
        expect(page).to have_selector('td span.badge', text: "12")
        expect(page).to have_content('11 Views')
        expect(page).to have_content('6 Downloads')
      end
    end
  end

  context "no files" do
    before do
      visit "/dashboard"
      expect(page).to have_content "Your Statistics"
    end
    it "includes the number of people who are following the user" do
      within('tr', text: "People you follow") do
        expect(page).to have_selector('td span.badge', text: "0")
      end
    end

    it "includes the number of people whom the user is following" do
      within('tr', text: "People who are following you") do
        expect(page).to have_selector('td span.badge', text: "0")
      end
    end
  end
end
