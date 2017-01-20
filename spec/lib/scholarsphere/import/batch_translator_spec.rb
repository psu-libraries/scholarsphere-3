# frozen_string_literal: true
require 'rails_helper'

describe Import::BatchTranslator do
  describe "default_prefix" do
    it "default prefix is batch" do
      expect(described_class.new({}).send(:default_prefix)).to eq("batch_")
    end
  end

  describe "#import" do
    let!(:work1) { create :work, id: 'x920fw89s' }
    let!(:work2) { create :work, id: 'tm70mv24n' }
    let!(:work3) { create :work, id: 'g445cd26c' }
    let(:batch_id) { 'zg64tk99d' }

    let(:sufia6_user) { "s6user" }
    let(:sufia6_password) { "s6password" }
    let(:translator) { described_class.new(import_dir: import_directory, import_binary: false) }

    let(:import_directory) { File.join(fixture_path, 'import') }
    let(:json_file_name) { File.join(import_directory, "batch_#{batch_id}.json") }
    let(:batch_metadata) { JSON.parse(File.read(json_file_name), symbolize_names: true) }

    it 'Creates related Work Links' do
      expect(Rails.logger).to receive(:debug).with("Importing batch_zg64tk99d.json")
      translator.import
      expect(work1.reload.related_object_ids).to eq ['tm70mv24n', 'g445cd26c']
      expect(work2.reload.related_object_ids).to eq ['x920fw89s', 'g445cd26c']
      expect(work3.reload.related_object_ids).to eq ['x920fw89s', 'tm70mv24n']
    end
  end
end
