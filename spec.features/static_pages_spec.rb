require_relative './feature_spec_helper'

describe "Static pages" do

  shared_examples "Verifies each static page" do |logged_in|
    before { create(:user) } if logged_in

    [
        '/about',
        '/help',
        '/contact'
    ].each do |path|
      describe "The '#{path}' page" do
        it "has verified hyperlinks" do
          verify_links(path)
        end
        unless logged_in
          # Verifying youtube links is done via visiting an external url.
          # We can only do so if we are not logged in as a user.
          it "has verified videos exist" do
            verfiy_youtube_links(path)
          end
        end
      end
    end
  end

  describe "When not logged in" do
    it_behaves_like "Verifies each static page", false
  end

  describe "When logged in" do
    it_behaves_like "Verifies each static page", true
  end

  def verify_links(path)
    visit path
    links_on_page = Array.new
    unique_links = Array.new
    anchored_links = Array.new
    unique_anchored_links = Array.new
  
    all('#content a').each do |page_link|
      unless ['delete','post','put'].include? page_link[:method]
        links_on_page << page_link[:href]
        anchored_links << page_link[:href] if page_link[:href].include? "#"
      end
    end
  
    unique_links = links_on_page.uniq
    unique_anchored_links = anchored_links.uniq
  
    unique_links.each do |href|
      next if href == '#'
      next if href.blank?
      next if href =~ /^(http|mailto|tel)/
      if href =~ /^\//m
        # link to different page
        visit href
      else
        # link on same page
        visit "#{path}/#{href}"
      end
      if unique_anchored_links.include? href
        anchor = href.split('#').last
        page.find("##{anchor}").should_not be_nil
      end
      expect(status_code).to be(200)
    end
  end
  
  def verfiy_youtube_links(path)
    # Check all iframes containing youtube links for valid youtube ids
    visit path
    all("iframe[src*='youtube']").each do |iframe|
      youtube_id = iframe[:src].split('embed/').last.split('?').first
      visit "https://gdata.youtube.com/feeds/api/videos/#{youtube_id}"
      expect(status_code).to be(200)
    end
  end
end
