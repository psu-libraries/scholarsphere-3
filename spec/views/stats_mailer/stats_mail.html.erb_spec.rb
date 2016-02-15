# frozen_string_literal: true
require 'spec_helper'

describe 'stats_mailer/stats_mail.html.erb', type: :view do
  let(:presenter) { StatsPresenter.new(start_datetime, end_datetime) }

  before do
    assign(:presenter, presenter)
    allow(presenter).to receive(:total_users).and_return(10)
    allow(presenter).to receive(:total_uploads).and_return(100)
    allow(presenter).to receive(:total_public_uploads).and_return(70)
    allow(presenter).to receive(:total_registered_uploads).and_return(20)
    allow(presenter).to receive(:total_private_uploads).and_return(10)
  end

  context "when single day" do
    let(:start_datetime) { DateTime.now }
    let(:end_datetime) { DateTime.now }

    before do
      allow(presenter).to receive(:single_day?).and_return(true)
    end

    it "draws report" do
      render
      page = Capybara::Node::Simple.new(rendered)
      expect(page).to have_selector("h1")
      expect(page).to have_text("Report for #{start_datetime}")
      expect(page).not_to have_text("to #{start_datetime}")
      expect(page).to have_text("Total Users 10")
      expect(page).to have_text("Total Uploads 100")
      expect(page).to have_text("Total Public Uploads 70")
      expect(page).to have_text("Total Registered Uploads 20")
      expect(page).to have_text("Total Private Uploads 10")
    end
  end

  context "when single day" do
    let(:start_datetime) { 1.day.ago }
    let(:end_datetime) { DateTime.now }

    before do
      allow(presenter).to receive(:single_day?).and_return(false)
    end

    it "draws report" do
      render
      page = Capybara::Node::Simple.new(rendered)
      expect(page).to have_selector("h1")
      expect(page).to have_text("Report for #{start_datetime} to #{end_datetime}")
    end
  end
end
