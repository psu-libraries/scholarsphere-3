# frozen_string_literal: true
require "rails_helper"

describe CurationConcerns::Renderers::AttributeRenderer do
  context "when schema.org locale information is missing" do
    subject { described_class.new(:size, "3").render }

    it "does not display microdata" do
      is_expected.to eq('<dt class="attribute-term">Size</dt><dd class="attribute size">3</dd>')
    end
  end

  context "when schema.org locale information is present" do
    subject { described_class.new(:creator, "Joe Schmoe").render }

    it "displays microdata" do
      is_expected.to include('itemtype="http://schema.org/Person"')
      is_expected.to include('itemprop="creator"')
      is_expected.to include('<span itemprop="name">Joe Schmoe</span>')
    end
  end
end
