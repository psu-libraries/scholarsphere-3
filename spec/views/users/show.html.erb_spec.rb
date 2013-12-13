require 'spec_helper'

describe 'users/show.html.erb' do

  let(:join_date) { 5.days.ago }
  
  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(stub_model(User, user_key: 'mjg'))
    assign(:user, stub_model(User, user_key: 'cam156', created_at: join_date))
    assign(:followers, [])
    assign(:following, [])
    assign(:trophies, [])
    assign(:events, [])
  end

  it "should draw 4 tabs" do
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
    it "should have the vitals" do
      render
      rendered.should match /<i class="icon-time"><\/i> Joined on #{join_date.strftime("%b %d, %Y")}/
      rendered.should_not match /<i class="icon-briefcase"><\/i>/
    end
  end

  describe "when user has a title" do
    before do
      assign(:user, stub_model(User, user_key: 'cam156', created_at: join_date, title: 'mrs'))
    end
    it "should have the vitals" do
      render
      rendered.should match /<i class="icon-time"><\/i> Joined on #{join_date.strftime("%b %d, %Y")}/
      rendered.should match /<i class="icon-briefcase"><\/i> Mrs/
    end
  end
end
