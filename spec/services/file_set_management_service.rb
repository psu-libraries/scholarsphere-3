# frozen_string_literal: true
require "rails_helper"

describe FileSetManagementService do
  describe "#create_derivatives" do
    let(:list) { ["1", "2", "3"] }

    context "when an id list is provided" do
      let(:service) { described_class.new(list) }

      it "regenerates thumbnails for each file set in the list" do
        expect(service).to receive(:queue_derivatives_job).with(instance_of(String)).exactly(3).times
        service.create_derivatives
      end
    end

    context "when no list is provided" do
      let(:service) { described_class.new }

      it "regenerates thumbnails for all file sets" do
        service.create_derivatives
      end
    end
  end

  describe "#characterize" do
    let(:list) { ["1", "2", "3"] }

    context "when an id list is provided" do
      let(:service) { described_class.new(list) }

      it "characterizes each file set in the list" do
        expect(service).to receive(:queue_characterization_job).with(instance_of(String)).exactly(3).times
        service.characterize
      end
    end

    context "when no list is provided" do
      let(:service) { described_class.new }

      it "characterizes all file sets" do
        service.characterize
      end
    end
  end
end
