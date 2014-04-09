require 'spec_helper'

describe "Static pages" do

  let(:user) { FactoryGirl.find_or_create(:user) }

  shared_examples "verifying each page" do |logged_in|
    before { sign_in user } if logged_in

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

    describe "Submitting the contact form" do
      before(:all) do
        ActionMailer::Base.deliveries = []
        submit_contact_form
      end
      it "Sends a thank you message" do
        @thank_you_message.subject.should == "ScholarSphere Contact Form - #{@contact_form_subject}"
      end
      it "Sends a 'Scholarsphere Form' message to the admin" do
        @admin_message.subject.should == "Contact Form:#{@contact_form_subject}"
      end
      it "Produces a plaintext section for Redmine" do
        redmine_part = @admin_message.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source
        redmine_part.should have_content "Email: #{@contact_form_email}"
      end
      it "Produces an HTML section for humans" do
        scholarsphere_form_part = @admin_message.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
        scholarsphere_form_part.should have_content @contact_form_email
      end
    end
  end

  describe "User is not logged in" do
    it_behaves_like "verifying each page", false
  end

  describe "User is logged in" do
    it_behaves_like "verifying each page", true
  end
end

def submit_contact_form
  @contact_form_email = "kurt@example.com"
  @contact_form_subject = "Help with file upload"
  visit '/contact'
  page.should have_content "Contact Form"
  select "Making changes to my content", from: "contact_form_category"
  fill_in "contact_form_name", with: "Kurt Baker"
  fill_in "contact_form_email", with: @contact_form_email
  fill_in "contact_form_subject", with: @contact_form_subject
  fill_in "contact_form_message", with: "Please help me to upload a file."
  click_button "Send"
  sent_messages = ActionMailer::Base.deliveries
  sent_messages.count.should == 2
  @thank_you_message = sent_messages.select { |message| message.to == ["#{@contact_form_email}"] }.first
  @admin_message = sent_messages.select { |message| message.from == ["scholarsphere-service-support@dlt.psu.edu"] }.first
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
      begin
        page.should have_selector("##{anchor}", visible: false)
      rescue => e
        page.should have_selector("##{anchor}")
      end
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
