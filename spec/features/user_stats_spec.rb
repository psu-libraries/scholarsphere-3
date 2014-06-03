require 'spec_helper'

describe "User Statistics" do
  let(:user_name) {"curator1"}
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
    # TODO: This really shouldn't be necessary
    unspoof_http_auth
    sign_in :curator
    visit "/dashboard"
  end

  it "should include the number of files deposited into Sufia" do
    page.should have_content "Your Statistics"
    page.should have_content "12 Files you've deposited into Sufia"
  end

  it "should include the number of people who are following the user" do
    page.should have_content "0 People you follow"
  end

  it "should include the number of people whom the user is following" do
    page.should have_content "0 People who are following you"
  end

end