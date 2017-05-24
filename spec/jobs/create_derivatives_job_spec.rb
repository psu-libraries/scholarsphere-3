# frozen_string_literal: true
require 'rails_helper'

describe CreateDerivativesJob do
  let(:file_set) { build(:file_set) }

  context "when the job fails" do
    before do
      allow(CurationConcerns::WorkingDirectory).to receive(:find_or_retrieve).and_return("filename")
      allow(file_set).to receive(:create_derivatives).and_raise(StandardError, "failed to create derivatives")
    end

    it "sends a message to the user" do
      expect(FileSetDerivativeFailureJob).to receive(:perform_later).with(file_set, kind_of(User))
      expect { described_class.perform_now(file_set, "file-id") }.to raise_error(StandardError)
    end
  end
end
