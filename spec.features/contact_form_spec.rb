require_relative './feature_spec_helper'

describe 'Contact form:' do
  let(:email_address) { 'kurt@example.com' }
  let(:email_subject) { 'Help with file upload' }

  before do
    visit '/contact'
    page.should have_content 'Contact Form'
    select 'Making changes to my content', from: 'contact_form_category'
    fill_in 'contact_form_name', with: 'Kurt Baker'
    fill_in 'contact_form_email', with: email_address
    fill_in 'contact_form_subject', with: email_subject
    fill_in 'contact_form_message', with: 'Please help me to upload a file.'
    click_button 'Send'
  end

  let(:sent_messages) { ActionMailer::Base.deliveries }
  let(:thank_you_message) {
    sent_messages.detect do |message|
      message.to == [email_address]
    end
  }
  let(:admin_message) {
    sent_messages.detect do |message|
      message.from == ['scholarsphere-service-support@dlt.psu.edu']
    end
  }

  it 'Sends a thank you message' do
    thank_you_message.subject.should == "ScholarSphere Contact Form - #{email_subject}"
  end

  it 'Sends a "Scholarsphere Form" message to the admin' do
    admin_message.subject.should == "Contact Form:#{email_subject}"
  end

  let(:plaintext_message) {
    admin_message.body.parts.find do |p|
      p.content_type.match /plain/
    end
  }

  it 'Produces a plaintext section for Redmine' do
    plaintext_message.should have_content "Email: #{email_address}"
  end

  let(:html_message) {
    admin_message.body.parts.find do |p|
      p.content_type.match /html/
    end
  }

  it 'Produces an HTML section for humans' do
    html_message.should have_content email_address
  end
end
