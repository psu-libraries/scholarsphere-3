# frozen_string_literal: true
require "rails_helper"

describe Rails.application.secrets do
  it "responds to google_analytics_tracking_id" do
    expect(subject).to respond_to(:google_analytics_tracking_id)
  end
  it "has the proper google analytics id" do
    expect(subject.google_analytics_tracking_id).to eq("UA-33252017-2")
  end
end
