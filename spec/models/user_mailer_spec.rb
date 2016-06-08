# frozen_string_literal: true
require 'spec_helper'

describe UserMailer do
  describe "#acknowledgment_email" do
    let(:form)    { { contact_form: { email: "email@somewhere.com", subject: "Selected topic" } } }
    let(:params)  { ActionController::Parameters.new(form) }
    let(:message) { described_class.acknowledgment_email(params) }

    specify do
      expect(message.to).to contain_exactly("email@somewhere.com")
      expect(message.from).to contain_exactly(Rails.application.config.action_mailer.default_options.fetch(:from))
      expect(message.subject).to eq("ScholarSphere Contact Form - Selected topic")
      expect(message.body.raw_source).to match(/Thank you for contacting us with your question/)
    end
  end
end
