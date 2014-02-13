require 'spec_helper'

include Warden::Test::Helpers

describe_options = { type: :feature }

describe "Visting the static pages" do

  before do
    # TODO: This really shouldn't be necessary
    #unspoof_http_auth
    #sign_in :curator
    #@user = User.where(login: 'curator1').first
    visit '/'
  end

  context "About page" do
    before do
      click_link "About"
    end

    it "shows without errors" do
      page.status_code.should == 200
      page.should have_css 'h1', text:"About"
    end

    it "allows contact form link" do
      click_link "Contact us"
      page.status_code.should == 200
      current_path.should == Sufia::Engine.routes.url_helpers.contact_path
      page.should have_css 'h1', text:"Contact"
    end

    it "allows help page link" do
      click_link "Help page"
      page.status_code.should == 200
      page.should have_css '#faq'
    end

    it "allows deposit agreement link" do
      first(:link, "Deposit Agreement").click
      page.status_code.should == 200
      page.should have_css 'h1', text:"ScholarSphere Deposit Agreement"
    end

  end

  context "Help page" do
    before do
      click_link "Help"
    end

    it "shows without errors" do
      page.status_code.should == 200
      page.should have_css '#faq'
    end

    it "allows contact form link" do
      first(:link, "Submit Contact Form").click
      page.status_code.should == 200
      page.should have_css 'h1', text:"Contact"
    end

    it "allows libraries link" do
      click_link "University Park and Campus Locations"
      page.status_code.should == 200
      page.should have_css 'h1', text:"Subject Libraries"
    end

  end

  it "allows version page load" do
    find("a[href='/versions/']").click
    page.status_code.should == 200
    page.should have_css 'h1', text:"Versions"
  end


end
