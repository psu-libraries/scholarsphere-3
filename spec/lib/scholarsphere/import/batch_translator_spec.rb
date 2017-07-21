# frozen_string_literal: true
require "rails_helper"

describe Import::BatchTranslator do
  describe "default_prefix" do
    it "default prefix is batch" do
      expect(described_class.new({}).send(:default_prefix)).to eq("batch_")
    end
  end

  describe "#import" do
    let!(:work1) { create :work, id: "x920fw89s" }
    let(:translator) { described_class.new(import_dir: import_directory, import_binary: false) }
    let(:import_directory) { Rails.root.join("tmp", "import_test") }
    let(:import_fixture_directory) { File.join(fixture_path, "import") }
    let(:json_file_name) { File.join(import_fixture_directory, "batch_#{batch_id}.json") }
    let(:batch_metadata) { JSON.parse(File.read(json_file_name), symbolize_names: true) }

    before do
      FileUtils.mkdir(import_directory) unless File.directory?(import_directory)
      FileUtils.cp(json_file_name, import_directory)
    end

    after do
      FileUtils.rm_r(import_directory)
      work1.destroy(eradicate: true)
    end

    context "with multiple works" do
      let!(:work2) { create :work, id: "tm70mv24n" }
      let!(:work3) { create :work, id: "g445cd26c" }
      let(:batch_id) { "zg64tk99d" }
      it "Creates related Work Links" do
        expect(Rails.logger).to receive(:debug).with("Importing batch_zg64tk99d.json")
        translator.import
        expect(work1.reload.upload_set).to eq batch_id
        expect(work2.reload.upload_set).to eq batch_id
        expect(work3.reload.upload_set).to eq batch_id
      end
    end

    context "with one work" do
      let(:batch_id) { "zg64tkabc" }
      it "Creates no links" do
        expect(Rails.logger).to receive(:debug).with("Importing batch_zg64tkabc.json")
        translator.import
        expect(work1.reload.related_object_ids).to eq []
      end
    end
  end
end
