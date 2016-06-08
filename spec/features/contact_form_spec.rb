# frozen_string_literal: true
require 'feature_spec_helper'

describe 'Contact form:', type: :feature do
  let(:user) { create(:user) }
  let(:email)         { "archivist1@example.com" }
  let(:email_subject) { "My Subject is Cool" }
  let(:sent_messages) { ActionMailer::Base.deliveries }
  let(:admin_message) {
    sent_messages.detect do |message|
      message.to == ["scholarsphere@servicedesk.css.psu.edu", "umg-up.its.scholarsphere-support@groups.ucs.psu.edu"]
    end
  }
  let(:thank_you_message) {
    sent_messages.detect do |message|
      message.to == [email]
    end
  }
  let(:plaintext_message) {
    admin_message.body.parts.find do |p|
      p.content_type.match(/plain/)
    end
  }
  let(:html_message) {
    admin_message.body.parts.find do |p|
      p.content_type.match(/html/)
    end
  }

  before { sign_in(user) }

  it "sends emails to the service desk and confirmations to the user" do
    visit '/'
    click_link "Contact"
    expect(page).to have_content "Contact Form"
    fill_in "contact_form_name", with: "Test McPherson"
    fill_in "contact_form_email", with: email
    fill_in "contact_form_message", with: "I am contacting you regarding ScholarSphere."
    fill_in "contact_form_subject", with: email_subject
    select "Depositing content", from: "contact_form_category"
    click_button "Send"
    expect(page).to have_content "Thank you for your message!"
    expect(admin_message.subject).to eq("ScholarSphere Contact Form - #{email_subject}")
    expect(html_message).to have_content email
    expect(plaintext_message).to have_content "Email: #{email}"
    expect(thank_you_message.subject).to eq("ScholarSphere Contact Form - #{email_subject}")
  end
end
