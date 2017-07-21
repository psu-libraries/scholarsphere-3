# frozen_string_literal: true

require "rails_helper"

describe ImportUrlJob do
  let(:user)           { create(:user) }
  let(:file_set)       { create(:file_set, user: user, import_url: "import_url") }
  let(:log)            { double }
  let(:mock_retriever) { double }
  let(:http_status) { true }
  let(:mock_http_result) { instance_double("HTTParty::Response", success?: http_status) }
  let(:file_name) { "Development Team Projects and Milestones (not downloaded).xlsx" }

  before do
    allow(log).to receive(:performing!)
    allow(BrowseEverything::Retriever).to receive(:new).and_return(mock_retriever)
    allow(mock_retriever).to receive(:retrieve)
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(false)
    allow(HTTParty).to receive(:head).and_return(mock_http_result)
  end

  it "sanitizes the file name" do
    expect(CurationConcerns.config.callback).to receive(:run).with(:after_import_url_success, file_set, user)
    expect(log).to receive(:success!)
    described_class.perform_now(file_set, file_name, log)
    expect(file_set.label).to eq("Development_Team_Projects_and_Milestones__not_downloaded_.xlsx")
  end

  context "http head fails" do
    let(:http_status) { false }
    let(:inbox) { user.mailbox.inbox }

    it "fails to add the content" do
      expect(log).to receive(:fail!)
      expect(file_set.original_file).to be_nil
      described_class.perform_now(file_set, file_name, log)
      expect(inbox.count).to eq(1)
      last_message = inbox[0].last_message
      expect(last_message.subject).to eq("File Import Error")
      expect(last_message.body).to eq("Error Downloading Content for <a href=\"/concern/file_sets/#{file_set.id}\">Development Team Projects and Milestones (not downloaded).xlsx</a>")
    end
  end
end
