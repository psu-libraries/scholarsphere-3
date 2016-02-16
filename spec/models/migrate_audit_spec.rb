# frozen_string_literal: true
require 'spec_helper'

describe MigrateAudit, type: :model do
  let(:credentials) { ActiveFedora.fedora_config.credentials }
  let(:fedora_url) { credentials[:url] + credentials[:base_path] }

  let(:f3_file_migrated) { FactoryGirl.create(:f3_file_migrated) }
  let(:f3_file_not_migrated) { FactoryGirl.create(:f3_file_not_migrated) }
  let(:f3_file_migrated_wrong) { FactoryGirl.create(:f3_file_migrated_wrong) }
  let(:f3_data) { [f3_file_migrated, f3_file_not_migrated, f3_file_migrated_wrong] }

  let(:auditor) { MigrateAuditFedora4.new(fedora_url, credentials[:user], credentials[:password]) }

  let(:results) do
    results = []
    auditor.audit(f3_data) do |result|
      results.push result
    end
    results
  end

  before(:all) do
    GenericFile.create(id: "111xyzfile") { |file| file.apply_depositor_metadata('dmc') }
    GenericFile.create(id: "333xyzfile") { |file| file.apply_depositor_metadata('dmc') }
  end

  context "with a file migrated correctly" do
    subject { results.find { |r| r.f3_pid == f3_file_migrated.f3_pid } }
    it "returns OK" do
      expect(subject.status).to eq("OK")
    end
    it "has a valid Fedora 4 URI" do
      expect(subject.f4_id).to eq("#{fedora_url}/11/1x/yz/fi/111xyzfile")
    end
  end

  context "with a file not migrated" do
    subject { results.find { |r| r.f3_pid == f3_file_not_migrated.f3_pid } }
    it "reports not found" do
      expect(subject.status).to eq("Not found")
    end
  end

  context "with a file migrated incorrectly" do
    subject { results.find { |r| r.f3_pid == f3_file_migrated_wrong.f3_pid } }
    it "reports models mismatch" do
      expect(subject.status).to eq("Models mismatch. Expected: GenericFileFake but found: GenericFile")
    end
  end
end
