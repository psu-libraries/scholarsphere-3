# frozen_string_literal: true
require 'rails_helper'

describe "Scholarsphere yaml config" do
  let(:config) { Rails.application.config }

  describe "ffmpeg_path" do
    subject { config.ffmpeg_path }
    it { is_expected.to eq("ffmpeg") }
  end

  describe "service_instance" do
    subject { config.service_instance }
    it { is_expected.to eq("example") }
  end

  describe "virtual_host" do
    subject { config.virtual_host }
    it { is_expected.to eq("http://example.com/") }
  end

  describe "stats_email" do
    subject { config.stats_email }
    it { is_expected.to eq("ScholarSphere Stats <umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu>") }
  end
end
