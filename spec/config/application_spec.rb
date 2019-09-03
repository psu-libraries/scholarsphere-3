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

  describe 'contact_email' do
    subject { config.contact_email }

    it { is_expected.to eq('ssphere-support@psu.edu') }
  end

  describe 'subject_prefix' do
    subject { config.subject_prefix }

    it { is_expected.to eq('ScholarSphere Contact Form - ') }
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

  describe 'Zip file size threshold' do
    subject { config.zipfile_size_threshold }

    it { is_expected.to eq(500_000_000) }
  end

  describe 'Public zip file directory' do
    subject { config.public_zipfile_directory }

    it { is_expected.to eq(Pathname.new('public/zip-test')) }
  end
end
