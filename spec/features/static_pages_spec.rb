# frozen_string_literal: true
require 'feature_spec_helper'

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'

describe 'Static pages:', type: :feature do
  shared_examples 'verify each static page' do |user|
    before do
      sign_in_with_js(user)
    end

    [
      '/about',
      '/help',
      '/contact'
    ].each do |path|
      describe "The '#{path}' page" do
        it 'has verified hyperlinks' do
          verify_links path
        end
        unless user
          # Verifying youtube links is done via visiting an external url.
          # We can only do so if we are not logged in as a user.
          it 'has verified videos exist', unless: $in_travis do
            verfiy_youtube_links path
          end
        end
      end
    end
  end

  describe 'When not logged in' do
    we_can 'verify each static page', nil
  end

  describe 'When logged in' do
    we_can 'verify each static page', FactoryGirl.find_or_create(:user)
  end

  def verify_links(path)
    visit path
    links_on_page = []
    anchored_links = []

    all('#content a').each do |page_link|
      unless ['delete', 'post', 'put'].include? page_link[:method]
        links_on_page << page_link[:href]
        anchored_links << page_link[:href] if page_link[:href].include?('#')
      end
    end

    unique_anchored_links = []
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
      if unique_anchored_links.include?(href)
        anchor = href.split('#').last
        expect(page).to have_selector "##{anchor}", visible: false
      end
      expect(status_code).to be 200
    end
  end

  def verfiy_youtube_links(path)
    # Check all iframes containing youtube links for valid youtube ids
    visit path
    srcs = []
    all('iframe[src*="youtube"]').each do |iframe|
      srcs << iframe[:src]
    end
    srcs.each do |url|
      visit url
      expect(status_code).to be 200
    end
  end
end
