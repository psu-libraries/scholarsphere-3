# frozen_string_literal: true
require 'rails_helper'

describe ImportUrlJob do
  let(:user)           { create(:user) }
  let(:file_set)       { create(:file_set, user: user, import_url: "import_url") }
  let(:log)            { double }
  let(:mock_retriever) { double }
  let(:file_name)      { "Development Team Projects and Milestones (not downloaded).xlsx" }

  before do
    allow(log).to receive(:performing!)
    allow(BrowseEverything::Retriever).to receive(:new).and_return(mock_retriever)
    allow(mock_retriever).to receive(:retrieve)
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
  end

  it "sanitizes the file name" do
    expect(CurationConcerns.config.callback).to receive(:run).with(:after_import_url_success, file_set, user)
    expect(log).to receive(:success!)
    described_class.perform_now(file_set, file_name, log)
    expect(file_set.label).to eq("Development_Team_Projects_and_Milestones__not_downloaded_.xlsx")
  end
end
