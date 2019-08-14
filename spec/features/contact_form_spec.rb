# frozen_string_literal: true

require 'feature_spec_helper'

describe 'Contact form:', type: :feature do
  let(:email_subject) { 'My Subject is Cool' }
  let(:user)          { create(:user, email: email) }
  let(:sent_messages) { ActionMailer::Base.deliveries }

  let(:contact_email) {
    sent_messages.find do |message|
      message.to == [Rails.application.config.contact_email]
    end
  }

  let(:user_email) {
    sent_messages.find do |message|
      message.to == [email]
    end
  }

  context 'when the user is outside of Penn State' do
    let(:email) { 'archivist1@example.com' }

    before { sign_in(user) }

    it 'sends emails to the contact email and confirmations to the user' do
      visit '/'
      click_link 'Contact'
      expect(page).to have_content 'Contact Form'
      expect(find_field('sufia_contact_form_name').value).to eq(user.name)
      expect(find_field('sufia_contact_form_email').value).to eq(email)
      fill_in 'sufia_contact_form_message', with: 'I am contacting you regarding ScholarSphere.'
      fill_in 'sufia_contact_form_subject', with: email_subject
      select 'Depositing content', from: 'sufia_contact_form_category'
      expect(page).to have_content('ReCaptcha')
      expect(page).to have_selector('div.g-recaptcha')
      click_button 'Send'
      expect(page).to have_content('Thank you for your message!')
      expect(contact_email.subject).to eq("ScholarSphere Contact Form - #{email_subject}")
      expect(user_email.to).to contain_exactly(email)
      expect(user_email.subject).to eq("ScholarSphere Contact Form - #{email_subject}")
    end
  end

  context 'when the user is from Penn State' do
    let(:email) { 'archivist1@psu.edu' }

    before { sign_in(user) }

    it 'sends email only to the contact email' do
      visit '/'
      click_link 'Contact'
      expect(page).to have_content 'Contact Form'
      expect(find_field('sufia_contact_form_name').value).to eq(user.name)
      expect(find_field('sufia_contact_form_email').value).to eq(email)
      fill_in 'sufia_contact_form_message', with: 'I am contacting you regarding ScholarSphere.'
      fill_in 'sufia_contact_form_subject', with: email_subject
      select 'Depositing content', from: 'sufia_contact_form_category'
      expect(page).to have_content('ReCaptcha')
      expect(page).to have_selector('div.g-recaptcha')
      click_button 'Send'
      expect(page).to have_content('Thank you for your message!')
      expect(contact_email.subject).to eq("ScholarSphere Contact Form - #{email_subject}")
      expect(user_email).to be_nil
    end
  end
end
