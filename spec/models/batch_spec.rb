# frozen_string_literal: true
require 'spec_helper'

describe Batch do
  context "when using Sufia::Lockable" do
    let(:manager) { ScholarsphereLockManager.new }
    let(:key) { "batch" }
    it "works with Redis 2.4" do
      expect(described_class).to receive(:lock_manager).and_return(manager)
      expect(manager).to receive(:lock).with(key)
      described_class.find_or_create(key)
    end
  end
end
