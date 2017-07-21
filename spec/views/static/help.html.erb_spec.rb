# frozen_string_literal: true
require "rails_helper"

describe "static/help.html.erb", type: :view do
  subject { rendered }
  before do
    assign(:page, ContentBlock.new)
  end

  context "when the user can not edit" do
    before do
      allow(view).to receive(:can?).and_return(false)
      render
    end

    it { is_expected.to match(/Frequently Asked Questions/) }
    it { is_expected.not_to match(/Edit/) }
  end

  context "when the user can edit" do
    before do
      allow(view).to receive(:can?).and_return(true)
      render
    end

    it { is_expected.to match(/Frequently Asked Questions/) }
    it { is_expected.to match(/Edit/) }
  end
end
