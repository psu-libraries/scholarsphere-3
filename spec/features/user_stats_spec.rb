require 'spec_helper'

describe "User Statistics" do
  let!(:current_user) { create :user }
  let(:user_name) {current_user.login}
  let(:conn) { ActiveFedora::SolrService.instance.conn }

  before do
    # More than 10 times, because the pagination threshold is 10
    12.times do |t|
      conn.add  id: "199#{t}", Solrizer.solr_name('depositor', :stored_searchable) => user_name
    end
    conn.commit
  end
  after do
    12.times do |t|
      conn.delete_by_id "199#{t}"
    end
    conn.commit
  end

  before do
    sign_in_as current_user
    visit "/dashboard"
    page.should have_content "Your Statistics"
  end

  it "should include the number of files deposited into Sufia" do
    within('tr', text:"Files you've deposited into Sufia") do
      expect(page).to have_selector('td span.label', text:"12")
    end
  end

  it "should include the number of people who are following the user" do
    within('tr', text:"People you follow") do
      expect(page).to have_selector('td span.label', text:"0")
    end
  end

  it "should include the number of people whom the user is following" do
    within('tr', text:"People who are following you") do
      expect(page).to have_selector('td span.label', text:"0")
    end
  end

end