# This file is a Work in Progress

require_relative '../feature_spec_helper'

describe 'Generic File Show:' do

  before do

  end

  context "When logged in with an uploaded file" do
    before do
      click_link @gf1.title.first
    end

    pending "I can see the file's page" do
      page.status_code.should == 200
      page.should have_content @gf1.title.first
    end

    pending "I can see the link for creator" do
      check_page(@gf1.creator.first)
    end

    pending "I can see the link for contributor" do
      check_page(@gf1.contributor.first)
    end

    pending "I can see the link for publisher" do
      check_page(@gf1.publisher.first)
    end

    pending "I can see the link for subject" do
      check_page(@gf1.subject.first)
    end

    pending "I can see the link for language" do
      check_page(@gf1.language.first)
    end

    pending "I can see the link for based_near" do
      check_page(@gf1.based_near.first)
    end

    pending "I can see the link for a tag" do
      check_page(@gf1.tag.first)
    end

    pending "I can see the link for rights" do
      check_page(@gf1.rights.first)
    end

    pending "I can see the link for all the linkable items" do
      page.should have_link 'http://example.org/TheDescriptionLink/'
      page.should have_link @gf1.related_url.first
    end

    pending "I can see the Mendeley modal" do
      click_link "Mendeley"
      page.should have_css(".modal-header")
    end

    pending "I can see the Zotero modal" do
      click_link "Zotero"
      page.should have_css(".modal-header")
    end

  end

  def check_page(link_name)
    page.should have_link link_name
    click_on link_name
    page.should have_content @gf1.title.first
    page.should_not have_content @gf2.title.first
  end

end