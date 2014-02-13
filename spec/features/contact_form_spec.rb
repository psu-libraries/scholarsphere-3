require 'spec_helper'

describe "Sending an email via the contact form" do

  before do
    sign_in :user_with_fixtures
  end

  it "should send mail" do
    ContactForm.any_instance.stub(:deliver).and_return(true)
    ActionMailer::Base.should_receive(:mail).with(
      :from=> Sufia::Engine.config.contact_form_delivery_from,
      :to=> "archivist1@example.com",
      :subject=> "ScholarSphere Contact Form - My Subject is Cool",
      :body=> Sufia::Engine.config.contact_form_delivery_body
    ).and_return true
    visit '/'
    click_link "Contact"
    page.should have_content "Contact Form"
    fill_in "contact_form_name", with: "Test McPherson" 
    fill_in "contact_form_email", with: "archivist1@example.com"
    fill_in "contact_form_message", with: "I am contacting you regarding ScholarSphere."
    fill_in "contact_form_subject", with: "My Subject is Cool"
    select "Depositing content", from: "contact_form_category"
    click_button "Send"
    page.should have_content "Thank you"
    # this step allows the delivery to go back to normal
    ContactForm.any_instance.unstub(:deliver)
  end

end