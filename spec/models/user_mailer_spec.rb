# frozen_string_literal: true

require 'rails_helper'

describe UserMailer do
  before :all do
    GenericWork.destroy_all
  end
  describe "#acknowledgment_email" do
    let(:form)    { { sufia_contact_form: { email: "email@somewhere.com", subject: "Selected topic" } } }
    let(:params)  { ActionController::Parameters.new(form) }
    let(:message) { described_class.acknowledgment_email(params) }

    it "sends an email to the user when the contact form is submitted" do
      expect(message.to).to contain_exactly("email@somewhere.com")
      expect(message.from).to contain_exactly(Rails.application.config.action_mailer.default_options.fetch(:from))
      expect(message.subject).to eq("ScholarSphere Contact Form - Selected topic")
      expect(message.body.raw_source).to match(/Thank you for contacting us with your question/)
    end
  end

  describe "#stats_email" do
    let(:message)      { described_class.stats_email(1.day.ago, DateTime.now) }
    let(:mock_service) { double }
    let(:csv)          { "a,b,c\nd,e,f\n" }
    let!(:generic_work) { create :work, :with_pdf }

    before do
      allow(GenericWorkListToCSVService).to receive(:new).with([generic_work]).and_return(mock_service)
      allow(mock_service).to receive(:csv).and_return(csv)
    end

    it "emails the report" do
      expect(message['from'].to_s).to eq(Rails.application.config.action_mailer.default_options.fetch(:from))
      expect(message['to'].to_s).to include("Test email")
      expect(message.parts.count).to eq(2) # attachment & body
      expect(message.parts[0].body).to include("Report for")
      expect(message.parts[0].attachment?).to be_falsey
      expect(message.parts[1].attachment?).to be_truthy
      expect(message.parts[1].body).to include(csv)
    end
  end
end
