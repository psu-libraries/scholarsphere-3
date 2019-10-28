# frozen_string_literal: true

require 'rails_helper'

describe UserMailer do
  before :all do
    GenericWork.destroy_all
  end

  let(:default_from_email) { Rails.application.config.action_mailer.default_options.fetch(:from) }

  describe '#acknowledgment_email' do
    context 'when the user is outside of Penn State' do
      let(:form)    { { sufia_contact_form: { email: 'email@somewhere.com', subject: 'Selected topic' } } }
      let(:params)  { ActionController::Parameters.new(form) }
      let(:message) { described_class.acknowledgment_email(params) }

      it 'sends a confirmation email to the user' do
        expect(message.to).to contain_exactly('email@somewhere.com')
        expect(message.from).to contain_exactly(default_from_email)
        expect(message.subject).to eq('ScholarSphere Contact Form - Selected topic')
        expect(message.body.raw_source).to match(/Thank you for contacting us with your question/)
      end
    end

    context 'when the user is from Penn State' do
      let(:form)    { { sufia_contact_form: { email: 'xyz123@psu.edu', subject: 'Selected topic' } } }
      let(:params)  { ActionController::Parameters.new(form) }
      let(:message) { described_class.acknowledgment_email(params) }

      it 'does not send a confirmation email to the user (ServiceNow will do this)' do
        expect(message.body).to be_empty
      end
    end
  end

  describe '#stats_email' do
    let(:message)      { described_class.stats_email(1.day.ago, DateTime.now) }
    let(:mock_service) { double }
    let(:csv)          { "a,b,c\nd,e,f\n" }
    let!(:generic_work) { create :work, date_uploaded: 2.hours.ago }

    before do
      allow(GenericWorkListToCSVService).to receive(:new).with([generic_work]).and_return(mock_service)
      allow(mock_service).to receive(:csv).and_return(csv)
    end

    it 'emails the report' do
      expect(message['from'].to_s).to eq(default_from_email)
      expect(message['to'].to_s).to include('Test email')
      expect(message.parts.count).to eq(2) # attachment & body
      expect(message.parts[0].body).to include('Report for')
      expect(message.parts[0]).not_to be_attachment
      expect(message.parts[1]).to be_attachment
      expect(message.parts[1].body).to include(csv)
    end
  end

  describe '#user_stats_email' do
    let(:user) { create(:user) }
    let(:message) { described_class.user_stats_email(user: user) }
    let(:body) { message.body.raw_source }

    context 'when the user has file downloads' do
      let(:user) { create(:user) }
      let(:mock_presenter) { instance_double(UserStatsPresenter, file_downloads: 8, total_files: 21, user: user) }

      before do
        allow(UserStatsPresenter).to receive(:new).and_return(mock_presenter)
      end

      it 'emails a user a report of their monthly downloads and views' do
        expect(message['from'].to_s).to eq(default_from_email)
        expect(message['to'].to_s).to include(user.email)
        expect(body).to include(I18n.t('statistic.user_stats.heading', date: Date.today.last_month.strftime('%B')))
        expect(body).to include('You had 8 new downloads last month across your 21 files')
        expect(body).to include("Dear #{user.name}")
      end
    end

    context 'when the user has no file downloads' do
      let(:mock_presenter) { instance_double(UserStatsPresenter, file_downloads: 0, total_files: 21) }

      before do
        allow(UserStatsPresenter).to receive(:new).and_return(mock_presenter)
      end

      it 'build a null message object' do
        expect(message['from'].to_s).to be_empty
        expect(message['to'].to_s).to be_empty
        expect(message.body).to be_empty
      end
    end
  end
end
