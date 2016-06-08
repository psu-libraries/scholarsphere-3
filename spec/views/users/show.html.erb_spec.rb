# frozen_string_literal: true
require 'spec_helper'

describe 'users/show.html.erb', type: :view do
  let(:join_date) { 5.days.ago }
  let(:user)      { build(:user) }
  let(:ability)   { double(current_user: user) }
  let(:presenter) { Sufia::UserProfilePresenter.new(user, ability) }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).and_return(true)
    assign(:user, user)
    assign(:presenter, presenter)
    render
  end

  describe "when the user doesn't have a title" do
    let(:user) { build(:user, title: nil, created_at: join_date) }
    it "draws 4 tabs" do
      pending("Profile tab seems to have been removed, see #283")
      page = Capybara::Node::Simple.new(rendered)
      expect(page).to have_selector("ul#myTab.nav.nav-tabs > li > a[href='#contributions']")
      expect(page).to have_selector("ul#myTab.nav.nav-tabs > li > a[href='#profile']")
      expect(page).to have_selector("ul#myTab.nav.nav-tabs > li > a[href='#proxies']")
      expect(page).to have_selector("ul#myTab.nav.nav-tabs > li > a[href='#activity_log']")
      expect(page).to have_selector(".tab-content > div#contributions.tab-pane")
      expect(page).to have_selector(".tab-content > div#profile.tab-pane")
      expect(page).to have_selector(".tab-content > div#proxies.tab-pane")
      expect(page).to have_selector(".tab-content > div#activity_log.tab-pane")
    end

    it "has the vitals" do
      expect(rendered).to match(/<span class="glyphicon glyphicon-time"><\/span> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).not_to match(/<dt>Title<\/dt>/)
    end
  end

  describe "when user has a title" do
    let(:user) { build(:user, created_at: join_date, title: "Mrs") }
    it "has the vitals" do
      expect(rendered).to match(/<span class="glyphicon glyphicon-time"><\/span> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).to match(/<dt>Title<\/dt>/)
      expect(rendered).to match(/<dd>Mrs<\/dd>/)
    end
  end
end
