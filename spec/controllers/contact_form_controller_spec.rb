# frozen_string_literal: true

require 'rails_helper'

describe ContactFormController, type: :controller do
  routes { Sufia::Engine.routes }

  let(:parameters) do
    {
      'category' => 'General inquiry or request',
      'name' => 'Jane Doe',
      'email' => 'jzd123@psu.edu',
      'subject' => 'Test subject',
      'message' => 'Test message'
    }
  end

  context 'when ReCaptcha is enabled' do
    before { Recaptcha.configuration.skip_verify_env.delete('test') }

    after  { Recaptcha.configuration.skip_verify_env.push('test') }

    # rubocop:disable Rails/HttpPositionalArguments
    it 'prevents the message from being sent' do
      expect(Sufia::ContactMailer).not_to receive(:contact)
      put :create, sufia_contact_form: parameters
      expect(flash[:error]).to eq('reCAPTCHA verification failed, please try again.')
    end
    # rubocop:enable Rails/HttpPositionalArguments
  end

  context 'when ReCaptcha is not enabled' do
    let(:mock_mailer) { instance_double('ActionMailer::MessageDelivery') }

    # rubocop:disable Rails/HttpPositionalArguments
    it 'sends the message' do
      expect(Sufia::ContactMailer).to receive(:contact).and_return(mock_mailer)
      expect(mock_mailer).to receive(:deliver_now)
      expect(UserMailer).to receive(:acknowledgment_email)
      put :create, sufia_contact_form: parameters
    end
    # rubocop:enable Rails/HttpPositionalArguments
  end
end
