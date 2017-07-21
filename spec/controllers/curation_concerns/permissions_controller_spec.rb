# frozen_string_literal: true
require "rails_helper"

describe CurationConcerns::PermissionsController do
  let(:curation_concern) { build(:work, id: "1234") }

  describe "#copy_access" do
    before do
      allow(controller).to receive(:curation_concern).and_return(curation_concern)
      allow(controller).to receive(:authorize!).with(:edit, curation_concern).and_return(true)
    end

    it "calls CopyPermissionsJob" do
      expect(CopyPermissionsJob).to receive(:perform_later).with(curation_concern)
      expect(controller).to receive(:redirect_to)
      controller.copy_access
    end
  end
end
