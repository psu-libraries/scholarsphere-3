# frozen_string_literal: true
require 'rails_helper'

describe ImportUrlJob do
  let(:user)           { create(:user) }
  let(:file_set)       { create(:file_set, user: user, import_url: "import_url") }
  let(:log)            { double }
  let(:mock_retriever) { double }

  before do
    allow(log).to receive(:performing!)
    allow(BrowseEverything::Retriever).to receive(:new).and_return(mock_retriever)
    allow(mock_retriever).to receive(:retrieve)
  end

  it "uses the file's original filename" do
    expect(CurationConcerns.config.callback).to receive(:run).with(:after_import_url_success, file_set, user)
    expect(log).to receive(:success!)
    described_class.perform_now(file_set, "file_name", log)
  end
end
