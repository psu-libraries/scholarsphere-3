require_relative './feature_spec_helper'

describe "Contact form:" do
  before do
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
    @thank_you_message = sent_messages.select { |message| message.to == ["#{@contact_form_email}"] }.first
    @admin_message = sent_messages.select { |message| message.from == ["scholarsphere-service-support@dlt.psu.edu"] }.first
  end
end
