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

  describe "derivatives path" do
    subject { config.derivatives_path }
    it { is_expected.to end_with("tmp/derivatives") }
  end

  describe "minter state file" do
    subject { config.minter_statefile }
    it { is_expected.to eq("/tmp/minter-state") }
  end
end
