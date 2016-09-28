# frozen_string_literal: true
require 'spec_helper'

describe Export::BatchConvertor do
  let(:generic_file1) { create(:file) }
  let(:generic_file2) { create(:file) }
  let(:batch) do
    Batch.new do |b|
      b.generic_files = [generic_file1, generic_file2]
      b.status = ["complete"]
    end
  end

  let(:json) { "{\"id\":null,\"status\":[\"complete\"],\"generic_file_ids\":[\"#{generic_file1.id}\",\"#{generic_file2.id}\"]}" }

  describe "to_json" do
    subject { described_class.new(batch).to_json }
    it { is_expected.to eq(json) }
  end
end
