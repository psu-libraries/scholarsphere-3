# frozen_string_literal: true

require 'rails_helper'

describe 'Application configuration' do
  let(:config) { Rails.application.config }

  describe 'ffmpeg_path' do
    subject { config.ffmpeg_path }

    it { is_expected.to eq('ffmpeg-test') }
  end

  describe 'service_instance' do
    subject { config.service_instance }

    it { is_expected.to eq('example-test') }
  end

  describe 'virtual_host' do
    subject { config.virtual_host }

    it { is_expected.to eq('http://test.com/') }
  end

  describe 'stats_email' do
    subject { config.stats_email }

    it { is_expected.to eq('Test email') }
  end

  describe 'derivatives path' do
    subject { config.derivatives_path }

    it { is_expected.to end_with('tmp/derivatives') }
  end

  describe 'Google analytics ID' do
    subject { config.google_analytics_id }

    it { is_expected.to eq('test-id') }
  end

  describe 'Upload limit' do
    subject { config.upload_limit }

    it { is_expected.to eq('10737418240') }
  end

  describe 'Network ingest directory' do
    subject { config.network_ingest_directory }

    it { is_expected.to eq(Pathname.new('tmp/ingest-test')) }
  end
end
