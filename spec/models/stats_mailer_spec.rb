# frozen_string_literal: true
require 'spec_helper'

describe StatsMailer, type: :model do
  let(:mock_service) { double }
  let(:csv) { "a,b,c\nd,e,f\n" }

  before do
    allow(GenericWorkListToCSVService).to receive(:new).and_return(mock_service)
    allow(mock_service).to receive(:csv).and_return(csv)
  end

  it "creates report" do
    delivered = described_class.stats_mail(1.day.ago, DateTime.now)
    expect(delivered['from'].to_s).to eq(ScholarSphere::Application.config.stats_from_email)
    expect(delivered['to'].to_s).to include("ScholarSphere Stats")
    expect(delivered.parts.count).to eq(2) # attachment & body
    expect(delivered.parts[0].body).to include("Report for")
    expect(delivered.parts[0].attachment?).to be_falsey
    expect(delivered.parts[1].attachment?).to be_truthy
    expect(delivered.parts[1].body).to include(csv)
  end
end
