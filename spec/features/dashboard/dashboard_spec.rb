require_relative '../feature_spec_helper'

include Selectors::Dashboard

describe 'The Dashboard', :type => :feature do

  let!(:current_user) { create :user }

  before do
    sign_in_as current_user
  end

  context "with files and collections" do
    let!(:generic_file) { GenericFile.new.tap do |f|
      f.apply_depositor_metadata(current_user.user_key)
      f.save
    end }
    let!(:collection)   { Collection.new.tap do |c|
      c.title = "test"
      c.apply_depositor_metadata(current_user.user_key)
      c.save
    end }

    before do
      go_to_dashboard
    end

    it "shows the user's statistics" do
      expect(page).to have_content("Your Statistics")
      expect(page).to have_content("1 Files you've deposited")
      expect(page).to have_content("1 Collections you've created")
      expect(page).to have_content("People you follow")
      expect(page).to have_content("People who are following you")
    end
  end

  context "without files and collections" do

    before do
      go_to_dashboard
    end

    it "displays information correctly" do
      # displays information about the user
      expect(page).to have_content "Joe Example"
      expect(page).to have_link "View Profile"
      expect(page).to have_link "Edit Profile"
      expect(page).to have_content("0 Files you've deposited")
      expect(page).to have_content("0 Collections you've created")

      # shows recent activity
      expect(page).to have_content "User Activity"
      expect(page).to have_content "User has no recent activity"
    end

    describe 'proxy portal' do

      context "with multiple current proxies" do
        let!(:second_user) { create(:user, display_name: "First Proxy") }
        let!(:third_user) { create(:user, display_name: "Second Proxy") }

        before do
          create_proxy_using_partial(second_user, third_user)
        end

        it "should list each proxy if both are authorized" do
          within("#authorizedProxies") do
            expect(page).to have_content(second_user.display_name)
            expect(page).to have_content(third_user.display_name)
          end
          go_to_dashboard
          within("#authorizedProxies") do
            expect(page).to have_content(second_user.display_name)
            expect(page).to have_content(third_user.display_name)
          end

          #should remove a proxy
          first(".remove-proxy-button").click
          go_to_dashboard
          within("#authorizedProxies") do
            expect(page).not_to have_content(second_user.display_name)
            expect(page).to have_content(third_user.display_name)
          end
        end

      end

    end
  end

end
