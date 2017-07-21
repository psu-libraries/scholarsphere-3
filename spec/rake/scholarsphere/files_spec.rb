# frozen_string_literal: true
require "rails_helper"
require "rake"

describe "scholarsphere:files" do
  before do
    load_rake_environment ["#{Rails.root}/lib/tasks/scholarsphere/files.rake"]
  end

  describe ":create_derivatives" do
    let(:mock_service) { double }

    before do
      allow(mock_service).to receive(:create_derivatives)
      allow(mock_service).to receive(:errors).and_return(0)
    end

    context "when no list is supplied" do
      it "uses all FileSets" do
        expect(FileSetManagementService).to receive(:new).with([]).and_return(mock_service)
        run_task("scholarsphere:files:create_derivatives")
      end
    end

    context "with a list of FileSet ids" do
      let(:argument) { "1 2 3" }
      it "uses all FileSets" do
        expect(FileSetManagementService).to receive(:new).with(["1", "2", "3"]).and_return(mock_service)
        run_task("scholarsphere:files:create_derivatives", argument)
      end
    end
  end

  describe ":characterize" do
    let(:mock_service) { double }

    before do
      allow(mock_service).to receive(:characterize)
      allow(mock_service).to receive(:errors).and_return(0)
    end

    context "when no list is supplied" do
      it "uses all FileSets" do
        expect(FileSetManagementService).to receive(:new).with([]).and_return(mock_service)
        run_task("scholarsphere:files:characterize")
      end
    end

    context "with a list of FileSet ids" do
      let(:argument) { "1 2 3" }
      it "uses all FileSets" do
        expect(FileSetManagementService).to receive(:new).with(["1", "2", "3"]).and_return(mock_service)
        run_task("scholarsphere:files:characterize", argument)
      end
    end
  end
end
