# frozen_string_literal: true
require 'spec_helper'

describe 'users/show.html.erb', type: :view do
  let(:join_date) { 5.days.ago }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'mjg'))
    allow(view).to receive(:can?).and_return(true)
    assign(:user, stub_model(User, user_key: 'cam156', created_at: join_date))
    assign(:followers, [])
    assign(:following, [])
    assign(:trophies, [])
    assign(:events, [])
  end

  it "draws 4 tabs" do
    pending("Profile tab seems to have been removed, see #278")
    render
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

  describe "when the user doesn't have a title" do
    it "has the vitals" do
      render
      expect(rendered).to match(/<i class="glyphicon glyphicon-time"><\/i> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).not_to match(/<i class="glyphicon glyphicon-briefcase"><\/i>/)
    end
  end

  describe "when user has a title" do
    before do
      assign(:user, stub_model(User, user_key: 'cam156', created_at: join_date, title: 'mrs'))
    end
    it "has the vitals" do
      render
      expect(rendered).to match(/<i class="glyphicon glyphicon-time"><\/i> Joined on #{join_date.strftime("%b %d, %Y")}/)
      expect(rendered).to match(/<i class="glyphicon glyphicon-briefcase"><\/i> Mrs/)
    end
  end
end
